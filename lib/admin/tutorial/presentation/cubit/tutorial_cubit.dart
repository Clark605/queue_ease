import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../shared/auth/data/datasources/firestore_user_datasource.dart';
import '../../../../shared/auth/domain/entities/user_entity.dart';
import 'tutorial_state.dart';

/// Manages first-time admin tutorial state.
///
/// Call [initialize] with the current [UserEntity] when the admin dashboard
/// loads. If the tutorial has not been completed, the cubit emits
/// [TutorialActive] for Step 1. The admin can then [advance] through each
/// step or [skip] the tutorial entirely.
///
/// Completion is persisted in Firestore via [FirestoreUserDatasource] so the
/// overlay is never shown again after the session.
@injectable
class TutorialCubit extends Cubit<TutorialState> {
  TutorialCubit(this._userDatasource, this._logger)
    : super(const TutorialHidden());

  final FirestoreUserDatasource _userDatasource;
  final AppLogger _logger;

  String? _uid;

  /// Initialises the tutorial based on [user.tutorialCompleted].
  ///
  /// If the tutorial has already been completed, emits [TutorialHidden].
  /// Otherwise emits [TutorialActive] at [TutorialStep.confirmProfile].
  void initialize(UserEntity user) {
    _uid = user.uid;
    if (user.tutorialCompleted) {
      _logger.debug(
        'TutorialCubit: tutorial already completed for uid=${user.uid}',
      );
      emit(const TutorialHidden());
    } else {
      _logger.info(
        'TutorialCubit: starting tutorial for uid=${user.uid}',
      );
      emit(const TutorialActive(TutorialStep.confirmProfile));
    }
  }

  /// Advances the tutorial to the next step.
  ///
  /// If already on the last step ([TutorialStep.acknowledgeReady]), persists
  /// completion and emits [TutorialCompleted].
  Future<void> advance() async {
    final current = state;
    if (current is! TutorialActive) return;

    final steps = TutorialStep.values;
    final nextIndex = steps.indexOf(current.step) + 1;

    if (nextIndex < steps.length) {
      _logger.debug(
        'TutorialCubit: advance → ${steps[nextIndex]}',
      );
      emit(TutorialActive(steps[nextIndex]));
    } else {
      await _complete();
    }
  }

  /// Skips the tutorial, persisting completion immediately.
  Future<void> skip() async {
    _logger.info('TutorialCubit: skip tutorial');
    await _complete();
  }

  Future<void> _complete() async {
    if (_uid != null) {
      try {
        await _userDatasource.markTutorialCompleted(_uid!);
        _logger.info(
          'TutorialCubit: tutorial completed for uid=$_uid',
        );
      } catch (e, st) {
        _logger.error(
          'TutorialCubit: failed to persist tutorial completion',
          e,
          st,
        );
      }
    }
    emit(const TutorialCompleted());
  }
}
