import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/organization/domain/entities/organization_entity.dart';
import '../../../../shared/organization/domain/repositories/organization_repository.dart';
import 'organization_state.dart';

/// Manages organization profile state and operations.
///
/// Provides real-time streaming of organization data via [watchOrganization]
/// and mutation operations via [updateOrganization].
///
/// The stream subscription is automatically cancelled when the cubit is closed.
@injectable
class OrganizationCubit extends Cubit<OrganizationState> {
  OrganizationCubit(this._organizationRepository, this._logger)
    : super(const OrganizationInitial());

  final OrganizationRepository _organizationRepository;
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
    _organizationSubscription = _organizationRepository
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
      final result = await _organizationRepository.updateOrganization(
        organization,
      );

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

  @override
  Future<void> close() {
    _organizationSubscription?.cancel();
    return super.close();
  }
}
