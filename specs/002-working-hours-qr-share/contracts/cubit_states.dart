// ignore: dangling_library_doc_comments
/// Contract: WorkingHoursCubit States
///
/// Sealed state hierarchy for WorkingHoursCubit.
/// FILE: lib/admin/working_hours/presentation/cubit/working_hours_state.dart

import 'package:equatable/equatable.dart';
import 'package:queue_ease/shared/organization/domain/entities/working_hours_entity.dart';

sealed class WorkingHoursState extends Equatable {
  const WorkingHoursState();
}

/// Initial state before any stream is started.
final class WorkingHoursInitial extends WorkingHoursState {
  const WorkingHoursInitial();

  @override
  List<Object?> get props => [];
}

/// Emitted while waiting for the first stream event.
final class WorkingHoursLoading extends WorkingHoursState {
  const WorkingHoursLoading();

  @override
  List<Object?> get props => [];
}

/// Emitted whenever the stream delivers working hours data.
/// [days] is always 7 entities, sorted by dayOfWeek 0–6.
final class WorkingHoursLoaded extends WorkingHoursState {
  const WorkingHoursLoaded(this.days);

  final List<WorkingHoursEntity> days;

  @override
  List<Object?> get props => [days];
}

/// Emitted while a "Save All" batch write is in flight.
final class WorkingHoursSaving extends WorkingHoursState {
  const WorkingHoursSaving();

  @override
  List<Object?> get props => [];
}

/// Emitted when "Save All" completes successfully.
/// Short-lived — the stream re-emits WorkingHoursLoaded immediately after.
final class WorkingHoursSaveSuccess extends WorkingHoursState {
  const WorkingHoursSaveSuccess();

  @override
  List<Object?> get props => [];
}

/// Emitted when the "Save All" write fails (validation or database error).
/// The stream is still alive; the user's edits are preserved in the page's
/// local state for retry.
final class WorkingHoursSaveError extends WorkingHoursState {
  const WorkingHoursSaveError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted when the Firestore stream itself fails.
/// The stream is broken; the page should show a full-screen error with retry.
final class WorkingHoursStreamError extends WorkingHoursState {
  const WorkingHoursStreamError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// ---------------------------------------------------------------------------
/// Contract: ShareAccessCubit States
///
/// Sealed state hierarchy for ShareAccessCubit.
/// FILE: lib/admin/share_access/presentation/cubit/share_access_state.dart

sealed class ShareAccessState extends Equatable {
  const ShareAccessState();
}

/// Default idle state — no pending action.
final class ShareAccessInitial extends ShareAccessState {
  const ShareAccessInitial();

  @override
  List<Object?> get props => [];
}

/// Emitted after the booking URL is successfully copied to clipboard.
final class ShareAccessLinkCopied extends ShareAccessState {
  const ShareAccessLinkCopied();

  @override
  List<Object?> get props => [];
}

/// Emitted while the QR image is being saved to the device gallery.
final class ShareAccessDownloading extends ShareAccessState {
  const ShareAccessDownloading();

  @override
  List<Object?> get props => [];
}

/// Emitted when the QR image has been successfully saved to the device gallery.
final class ShareAccessDownloaded extends ShareAccessState {
  const ShareAccessDownloaded();

  @override
  List<Object?> get props => [];
}

/// Emitted when any share/copy/download action fails.
final class ShareAccessError extends ShareAccessState {
  const ShareAccessError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
