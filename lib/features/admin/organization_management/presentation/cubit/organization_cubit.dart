import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../../../../features/shared_domain/entities/organization_entity.dart';
import '../../domain/repositories/admin_organization_repository.dart';
import 'organization_state.dart';

/// Manages organization profile state and operations for admin users.
///
/// Uses the unified [AdminOrganizationRepository] for all operations,
/// eliminating the previous dual-injection anti-pattern.
@injectable
class OrganizationCubit extends Cubit<OrganizationState> {
  OrganizationCubit(this._repository, this._logger)
    : super(const OrganizationInitial());

  final AdminOrganizationRepository _repository;
  final AppLogger _logger;

  StreamSubscription<OrganizationEntity>? _organizationSubscription;

  /// Watches organization data in real-time.
  ///
  /// Emits [OrganizationLoading] initially, then [OrganizationLoaded] whenever
  /// the organization document changes in Firestore.
  ///
  /// Any previous subscription is cancelled before starting a new one.
  Future<void> watchOrganization(String orgId) async {
    _logger.info('OrganizationCubit: watchOrganization → $orgId');
    emit(const OrganizationLoading());

    // Cancel any existing subscription
    await _organizationSubscription?.cancel();

    // Subscribe to organization stream
    _organizationSubscription = _repository
        .watchOrganization(orgId)
        .listen(
          (organization) {
            _logger.info(
              'OrganizationCubit: received update → ${organization.name}',
            );
            emit(OrganizationLoaded(organization));
          },
          onError: (error, stackTrace) {
            _logger.error(
              'OrganizationCubit: watchOrganization stream error',
              error,
              stackTrace,
            );
            emit(
              OrganizationError(
                error is AppException
                    ? error.message
                    : 'Failed to load organization',
              ),
            );
          },
        );
  }

  /// Updates the organization profile.
  ///
  /// Emits [OrganizationError] on failure. On success, the real-time stream
  /// will automatically re-emit [OrganizationLoaded] with the updated data.
  /// Does not emit [OrganizationLoading] to avoid clobbering the current view.
  Future<void> updateOrganization(OrganizationEntity organization) async {
    _logger.info(
      'OrganizationCubit: updateOrganization → ${organization.name}',
    );

    try {
      final result = await _repository.updateOrganization(organization);

      result.when(
        success: (_) {
          _logger.info('OrganizationCubit: updateOrganization succeeded');
          // The stream will emit the updated organization automatically,
          // so we don't need to manually emit OrganizationLoaded here
        },
        failure: (exception) {
          _logger.warning(
            'OrganizationCubit: updateOrganization failed',
            exception,
          );
          emit(OrganizationError(exception.message));
        },
      );
    } catch (e, st) {
      _logger.error(
        'OrganizationCubit: updateOrganization unexpected error',
        e,
        st,
      );
      emit(const OrganizationError('Something went wrong. Please try again.'));
    }
  }

  /// Optimistically toggles the open/closed status for the organization.
  ///
  /// Emits the updated organization immediately, then rolls back on failure.
  Future<void> toggleOrganizationOpen(bool isOpen) async {
    final currentState = state;
    if (currentState is! OrganizationLoaded) {
      emit(const OrganizationError('Organization data not loaded'));
      return;
    }

    final previousOrganization = currentState.organization;
    final updatedOrganization = previousOrganization.copyWith(isOpen: isOpen);

    emit(OrganizationLoaded(updatedOrganization));

    try {
      final result = await _repository.updateOrganization(updatedOrganization);

      result.when(
        success: (_) {
          _logger.info('OrganizationCubit: toggleOrganizationOpen succeeded');
        },
        failure: (exception) {
          _logger.warning(
            'OrganizationCubit: toggleOrganizationOpen failed',
            exception,
          );
          emit(
            OrganizationError(
              'Failed to update status. Please try again.',
              organization: previousOrganization,
            ),
          );
        },
      );
    } catch (e, st) {
      _logger.error(
        'OrganizationCubit: toggleOrganizationOpen unexpected error',
        e,
        st,
      );
      emit(
        OrganizationError(
          'Failed to update status. Please try again.',
          organization: previousOrganization,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _organizationSubscription?.cancel();
    return super.close();
  }
}
