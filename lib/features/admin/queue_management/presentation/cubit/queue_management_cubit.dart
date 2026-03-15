import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';
import '../../../../shared_domain/entities/appointment_status.dart';
import '../../domain/repositories/admin_appointment_repository.dart';
import '../../domain/use_cases/advance_queue_use_case.dart';
import '../../domain/use_cases/generate_daily_queue_use_case.dart';
import '../../domain/use_cases/mark_no_show_use_case.dart';
import '../../domain/use_cases/rejoin_skipped_use_case.dart';
import '../../domain/use_cases/skip_queue_entry_use_case.dart';
import '../../domain/use_cases/watch_daily_queue_use_case.dart';
import 'queue_management_state.dart';

/// Manages admin queue state for the queue management UI.
///
/// Subscribes to the live [WatchDailyQueueUseCase] stream and exposes
/// action methods that delegate to the respective use cases. Actions emit
/// [QueueManagementActionInFlight] while in flight and return to
/// [QueueManagementLoaded] on success; the live stream then emits the
/// authoritative updated snapshot automatically.
@injectable
class QueueManagementCubit extends Cubit<QueueManagementState> {
  QueueManagementCubit(
    this._repository,
    this._generateQueue,
    this._watchDailyQueue,
    this._advanceQueue,
    this._skipQueueEntry,
    this._markNoShow,
    this._rejoinSkipped,
    this._logger,
  ) : super(const QueueManagementInitial());

  final AdminAppointmentRepository _repository;
  final GenerateDailyQueueUseCase _generateQueue;
  final WatchDailyQueueUseCase _watchDailyQueue;
  final AdvanceQueueUseCase _advanceQueue;
  final SkipQueueEntryUseCase _skipQueueEntry;
  final MarkNoShowUseCase _markNoShow;
  final RejoinSkippedUseCase _rejoinSkipped;
  final AppLogger _logger;

  StreamSubscription<Result<AdminQueueSnapshot>>? _queueSub;
  StreamSubscription<List<AppointmentEntity>>? _appointmentsSub;
  bool _isAutoGenerateInFlight = false;

  static const _loadQueueFallbackMessage =
      'Unable to load queue data right now. Please try again.';
  static const _updateQueueFallbackMessage =
      'Unable to update queue right now. Please try again.';

  String _resolveLoadMessage(String message) {
    final trimmed = message.trim();
    return trimmed.isEmpty ? _loadQueueFallbackMessage : trimmed;
  }

  String _resolveActionMessage(String message) {
    final trimmed = message.trim();
    return trimmed.isEmpty ? _updateQueueFallbackMessage : trimmed;
  }

  /// Starts watching today's queue for [orgId].
  ///
  /// Cancels any prior subscription before starting a new one. Emits
  /// [QueueManagementLoading] immediately, then [QueueManagementLoaded]
  /// or [QueueManagementError] as stream events arrive.
  void watchQueue({required String orgId, required DateTime date}) {
    emit(const QueueManagementLoading());
    _queueSub?.cancel();
    _appointmentsSub?.cancel();
    _queueSub = _watchDailyQueue(orgId: orgId, date: date).listen(
      (result) {
        switch (result) {
          case Success(:final data):
            emit(QueueManagementLoaded(snapshot: data));
          case Failure(:final exception):
            _logger.error('QueueManagementCubit: watch error', exception);
            emit(
              QueueManagementError(
                message: _resolveLoadMessage(exception.message),
              ),
            );
        }
      },
      onError: (Object e, StackTrace st) {
        _logger.error('QueueManagementCubit: stream error', e, st);
        emit(const QueueManagementError(message: _loadQueueFallbackMessage));
      },
    );

    _appointmentsSub = _repository
        .watchAppointmentsByDate(orgId: orgId, date: date)
        .listen(
          (appointments) {
            final hasBooked = appointments.any(
              (appointment) => appointment.status == AppointmentStatus.booked,
            );
            if (hasBooked) {
              _autoGenerateQueue(orgId: orgId, date: date);
            }
          },
          onError: (Object e, StackTrace st) {
            _logger.error(
              'QueueManagementCubit: appointment watch error',
              e,
              st,
            );
          },
        );
  }

  Future<void> _autoGenerateQueue({
    required String orgId,
    required DateTime date,
  }) async {
    if (_isAutoGenerateInFlight) return;

    _isAutoGenerateInFlight = true;
    final result = await _generateQueue(orgId: orgId, date: date);
    switch (result) {
      case Success():
        break;
      case Failure(:final exception):
        _logger.error(
          'QueueManagementCubit: auto-generate queue failed',
          exception,
        );
    }
    _isAutoGenerateInFlight = false;
  }

  /// Generates (or idempotently refreshes) today's queue from booked appointments.
  ///
  /// Emits [QueueManagementLoading] while in progress. On success the live
  /// stream delivers the updated snapshot automatically. On failure emits
  /// [QueueManagementError].
  Future<void> generateQueue({
    required String orgId,
    required DateTime date,
  }) async {
    emit(const QueueManagementLoading());
    _logger.info(
      'QueueManagementCubit',
      'Generating queue for $orgId on $date',
    );
    final result = await _generateQueue(orgId: orgId, date: date);
    switch (result) {
      case Success():
        // The watchDailyQueue stream will emit the updated snapshot.
        break;
      case Failure(:final exception):
        _logger.error('QueueManagementCubit: generateQueue failed', exception);
        emit(
          QueueManagementError(
            message: _resolveActionMessage(exception.message),
          ),
        );
    }
  }

  /// Returns the snapshot from the current loaded or in-flight state, or null.
  AdminQueueSnapshot? get _currentSnapshot => switch (state) {
    QueueManagementLoaded(:final snapshot) => snapshot,
    QueueManagementActionInFlight(:final snapshot) => snapshot,
    _ => null,
  };

  /// Marks the current entry as completed and promotes the next.
  Future<void> next({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) => _runAction(
    action: () =>
        _advanceQueue(orgId: orgId, date: date, appointmentId: appointmentId),
    actionName: 'next',
  );

  /// Moves the current entry to the end of the queue.
  Future<void> skip({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) => _runAction(
    action: () =>
        _skipQueueEntry(orgId: orgId, date: date, appointmentId: appointmentId),
    actionName: 'skip',
  );

  /// Marks the current entry as no-show and promotes the next.
  Future<void> markNoShow({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) => _runAction(
    action: () =>
        _markNoShow(orgId: orgId, date: date, appointmentId: appointmentId),
    actionName: 'markNoShow',
  );

  /// Rejoins a skipped or no-show entry by appending it to the queue end.
  Future<void> rejoin({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) => _runAction(
    action: () =>
        _rejoinSkipped(orgId: orgId, date: date, appointmentId: appointmentId),
    actionName: 'rejoin',
  );

  Future<void> _runAction({
    required Future<Result<void>> Function() action,
    required String actionName,
  }) async {
    final snapshot = _currentSnapshot;
    if (snapshot == null) return;

    emit(QueueManagementActionInFlight(snapshot: snapshot));
    _logger.info('QueueManagementCubit', 'Running action: $actionName');

    final result = await action();
    switch (result) {
      case Success():
        // Restore Loaded so the UI is unblocked while the live stream
        // delivers the authoritative post-action snapshot.
        emit(QueueManagementLoaded(snapshot: snapshot));
      case Failure(:final exception):
        _logger.error('QueueManagementCubit: $actionName failed', exception);
        emit(
          QueueManagementError(
            message: _resolveActionMessage(exception.message),
          ),
        );
    }
  }

  @override
  Future<void> close() {
    _queueSub?.cancel();
    _appointmentsSub?.cancel();
    return super.close();
  }
}
