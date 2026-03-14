import 'package:equatable/equatable.dart';

/// Steps in the first-time admin tutorial.
///
/// Ordered: [confirmProfile] → [addService] → [acknowledgeReady].
enum TutorialStep {
  /// Step 1: Review and confirm the organization profile.
  confirmProfile,

  /// Step 2: Create the first service for the organization.
  addService,

  /// Step 3: Final acknowledgement — organization is ready to accept queues.
  acknowledgeReady,
}

/// Base class for all tutorial states.
sealed class TutorialState extends Equatable {
  const TutorialState();
}

/// Tutorial is not shown — either already completed or not applicable.
final class TutorialHidden extends TutorialState {
  const TutorialHidden();

  @override
  List<Object?> get props => [];
}

/// Tutorial overlay is visible and the admin is on [step].
final class TutorialActive extends TutorialState {
  const TutorialActive(this.step);

  final TutorialStep step;

  @override
  List<Object?> get props => [step];
}

/// The admin has completed or skipped the tutorial.
///
/// Emitted transiently to allow the UI to show a "You're all set!" moment
/// before fully hiding the overlay.
final class TutorialCompleted extends TutorialState {
  const TutorialCompleted();

  @override
  List<Object?> get props => [];
}
