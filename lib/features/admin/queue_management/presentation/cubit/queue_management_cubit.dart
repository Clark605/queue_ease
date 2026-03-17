import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../shared_domain/entities/appointment_entity.dart';
import '../../../../shared_domain/entities/appointment_status.dart';
import '../../domain/models/queue_automation_state.dart';
import '../../domain/repositories/admin_appointment_repository.dart';
import '../../domain/services/queue_deadline_evaluator.dart';
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
  StreamSubscription<int>? _countdownTickerSub;
  bool _isAutoGenerateInFlight = false;
  bool _isAutoNoShowInFlight = false;
  String? _autoNoShowPendingId;
  String? _activeOrgId;
  DateTime? _activeQueueDate;
  final _queueDeadlineEvaluator = const QueueDeadlineEvaluator();

  static const _loadQueueFallbackMessage =
      'Unable to load queue data right now. Please try again.';
  static const _updateQueueFallbackMessage =
      'Unable to update queue right now. Please try again.';
  static const _autoNoShowSuccessMessage =
      'Overdue customer was marked no-show automatically.';

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
    _activeOrgId = orgId;
    _activeQueueDate = date;
    emit(const QueueManagementLoading());
    _queueSub?.cancel();
    _appointmentsSub?.cancel();
    _queueSub = _watchDailyQueue(orgId: orgId, date: date).listen(
      (result) {
        switch (result) {
          case Success(:final data):
            emit(
              QueueManagementLoaded(
                snapshot: data,
                evaluatedAt: DateTime.now(),
              ),
            );
            _autoNoShowPendingId = null;
            _syncCountdownTicker(data);
            _maybeProcessOverdueFront(data);
          case Failure(:final exception):
            _logger.error('QueueManagementCubit: watch error', exception);
            _stopCountdownTicker();
            emit(
              QueueManagementError(
                message: _resolveLoadMessage(exception.message),
              ),
            );
        }
      },
      onError: (Object e, StackTrace st) {
        _logger.error('QueueManagementCubit: stream error', e, st);
        _stopCountdownTicker();
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

  /// Explicitly marks the current front entry as serving.
  Future<void> startServing({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  }) => _runAction(
    action: () => _repository.startServing(
      orgId: orgId,
      date: date,
      appointmentId: appointmentId,
    ),
    actionName: 'startServing',
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

    emit(
      QueueManagementActionInFlight(
        snapshot: snapshot,
        evaluatedAt: DateTime.now(),
      ),
    );
    _logger.info('QueueManagementCubit', 'Running action: $actionName');

    final result = await action();
    switch (result) {
      case Success():
        // Restore Loaded so the UI is unblocked while the live stream
        // delivers the authoritative post-action snapshot.
        emit(
          QueueManagementLoaded(
            snapshot: snapshot,
            evaluatedAt: DateTime.now(),
            feedbackMessage: _actionSuccessMessage(actionName),
          ),
        );
        _syncCountdownTicker(snapshot);
      case Failure(:final exception):
        _logger.error('QueueManagementCubit: $actionName failed', exception);
        emit(
          QueueManagementError(
            message: _resolveActionMessage(exception.message),
          ),
        );
    }
  }

  String? _actionSuccessMessage(String actionName) {
    return switch (actionName) {
      'rejoin' => 'Customer rejoined and moved to the end of queue.',
      'markNoShow' => 'Customer marked as no-show.',
      'startServing' => 'Customer marked as serving.',
      'skip' => 'Customer moved to the end of queue.',
      'next' => 'Current service completed.',
      _ => null,
    };
  }

  @override
  Future<void> close() {
    _queueSub?.cancel();
    _appointmentsSub?.cancel();
    _countdownTickerSub?.cancel();
    return super.close();
  }

  void _syncCountdownTicker(AdminQueueSnapshot snapshot) {
    final currentEntry = snapshot.current;
    if (currentEntry == null) {
      _stopCountdownTicker();
      return;
    }

    final canTick =
        currentEntry.status != AppointmentStatus.completed &&
        currentEntry.status != AppointmentStatus.noShow;
    if (!canTick) {
      _stopCountdownTicker();
      return;
    }

    _countdownTickerSub ??= Stream<int>.periodic(
      const Duration(seconds: 1),
      (tick) => tick,
    ).listen((_) => _emitTickIfNeeded());
  }

  void _stopCountdownTicker() {
    _countdownTickerSub?.cancel();
    _countdownTickerSub = null;
  }

  void _emitTickIfNeeded() {
    final loadedState = switch (state) {
      QueueManagementLoaded() => state as QueueManagementLoaded,
      _ => null,
    };
    if (loadedState == null) return;

    final current = loadedState.snapshot.current;
    if (current == null) {
      _stopCountdownTicker();
      return;
    }

    final evaluation = _queueDeadlineEvaluator.evaluate(
      now: DateTime.now(),
      scheduledAt: current.scheduledAt,
      effectiveTimeMarginMinutes: current.effectiveTimeMarginMinutes,
      status: current.status,
    );

    final nextCurrent = current.copyWith(
      automationState: evaluation.state,
      allowedActions: evaluation.allowedActions,
      noShowDeadline: evaluation.noShowDeadline,
      remainingSeconds: evaluation.remainingSeconds,
    );
    final nextSnapshot = loadedState.snapshot.copyWith(current: nextCurrent);

    emit(
      QueueManagementLoaded(
        snapshot: nextSnapshot,
        evaluatedAt: DateTime.now(),
      ),
    );

    if (evaluation.state == QueueAutomationState.serving ||
        evaluation.state == QueueAutomationState.overdue) {
      _stopCountdownTicker();
    }

    _maybeProcessOverdueFront(nextSnapshot);
  }

  Future<void> _maybeProcessOverdueFront(AdminQueueSnapshot snapshot) async {
    final orgId = _activeOrgId;
    final queueDate = _activeQueueDate;
    final current = snapshot.current;
    if (orgId == null || queueDate == null || current == null) {
      return;
    }

    final isOverdueFront =
        current.automationState == QueueAutomationState.overdue &&
        current.status != AppointmentStatus.serving;
    if (!isOverdueFront ||
        _isAutoNoShowInFlight ||
        _autoNoShowPendingId == current.appointmentId) {
      return;
    }

    _isAutoNoShowInFlight = true;
    _autoNoShowPendingId = current.appointmentId;
    final result = await _repository.markOverdueNoShow(
      orgId: orgId,
      date: queueDate,
      appointmentId: current.appointmentId,
    );
    switch (result) {
      case Success():
        _logger.info('QueueManagementCubit: auto no-show applied', {
          'appointmentId': current.appointmentId,
        });
        emit(
          QueueManagementLoaded(
            snapshot: snapshot,
            evaluatedAt: DateTime.now(),
            feedbackMessage: _autoNoShowSuccessMessage,
          ),
        );
      case Failure(:final exception):
        _logger.error('QueueManagementCubit: auto no-show failed', exception);
        _autoNoShowPendingId = null;
        // Restart the ticker so the UI can recover from transient failures.
        // Without this, the timer stays stopped on "Overdue" with no recovery
        // path until the next Firestore stream event.
        final snap = _currentSnapshot;
        if (snap != null) _syncCountdownTicker(snap);
    }
    _isAutoNoShowInFlight = false;
  }
}
