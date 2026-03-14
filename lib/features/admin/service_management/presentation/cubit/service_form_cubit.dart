import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:queue_ease/features/shared_domain/entities/service_entity.dart';

import 'service_form_state.dart';

/// Manages ephemeral UI state for [ServiceFormPage].
///
/// Handles stepper increments/decrements and the active toggle —
/// the three values that change reactively inside the form before submission.
///
/// Not annotated with [@injectable] — this cubit is scoped to a single route
/// and is created inline via [BlocProvider] in [ServiceFormPage], seeded from
/// the [ServiceEntity] being edited (or defaults for new services).
class ServiceFormCubit extends Cubit<ServiceFormState> {
  ServiceFormCubit({ServiceEntity? initial})
    : super(
        ServiceFormState(
          duration:
              initial?.durationMinutes ?? ServiceFormState.defaultDuration,
          margin: initial?.timeMarginMinutes ?? ServiceFormState.defaultMargin,
          isActive: initial?.isActive ?? true,
        ),
      );

  // ---------------------------------------------------------------------------
  // Bounds — exposed as static constants so the UI can drive null callbacks
  // ---------------------------------------------------------------------------

  static const int durationStep = 5;
  static const int durationMin = 5;
  static const int durationMax = 240;
  static const int marginStep = 5;
  static const int marginMin = 0;
  static const int marginMax = 60;

  // ---------------------------------------------------------------------------
  // Mutations
  // ---------------------------------------------------------------------------

  void decrementDuration() {
    if (state.duration > durationMin) {
      emit(state.copyWith(duration: state.duration - durationStep));
    }
  }

  void incrementDuration() {
    if (state.duration < durationMax) {
      emit(state.copyWith(duration: state.duration + durationStep));
    }
  }

  void decrementMargin() {
    emit(
      state.copyWith(
        margin: (state.margin - marginStep).clamp(marginMin, marginMax),
      ),
    );
  }

  void incrementMargin() {
    emit(
      state.copyWith(
        margin: (state.margin + marginStep).clamp(marginMin, marginMax),
      ),
    );
  }

  void setActive(bool value) => emit(state.copyWith(isActive: value));
}
