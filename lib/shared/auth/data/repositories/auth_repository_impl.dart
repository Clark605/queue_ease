import 'package:injectable/injectable.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/user_session_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../admin/organization/domain/repositories/admin_organization_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/firestore_user_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._authDatasource,
    this._firestoreDatasource,
    this._sessionService,
    this._adminOrganizationRepository,
    this._logger,
  );

  final FirebaseAuthDatasource _authDatasource;
  final FirestoreUserDatasource _firestoreDatasource;
  final UserSessionService _sessionService;
  final AdminOrganizationRepository _adminOrganizationRepository;
  final AppLogger _logger;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _authDatasource.currentUser;
    if (firebaseUser == null) {
      _logger.debug('AuthRepository: getCurrentUser → no active session');
      return null;
    }

    // Always fetch the full profile from Firestore so that fields like
    // organizationId and tutorialCompleted are always present.
    final profile = await _firestoreDatasource.getUser(firebaseUser.uid);
    if (profile == null) {
      _logger.warning(
        'AuthRepository: getCurrentUser → no Firestore profile uid=${firebaseUser.uid}',
      );
      return null;
    }
    await _sessionService.saveRole(profile.role);
    _logger.info(
      'AuthRepository: getCurrentUser → authenticated uid=${firebaseUser.uid} '
      'role=${profile.role.name} orgId=${profile.organizationId}',
    );
    return profile;
  }

  @override
  Future<UserEntity> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _logger.info('AuthRepository: signInWithEmailPassword → $email');
    final credential = await _authDatasource.signInWithEmailPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final profile = await _firestoreDatasource.getUser(uid);
    if (profile == null) {
      throw const DatabaseException(
        'No profile found for this account. Please contact support.',
      );
    }
    await _sessionService.saveRole(profile.role);
    _logger.debug('AuthRepository: role cached after email sign-in uid=$uid');
    return profile;
  }

  @override
  Future<UserEntity> signUpWithEmailPassword({
    required String email,
    required String password,
    required UserRole role,
    required String displayName,
    String? phone,
    String? orgName,
  }) async {
    _logger.info(
      'AuthRepository: signUpWithEmailPassword → $email role=${role.name}',
    );
    final credential = await _authDatasource.signUpWithEmailPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final profile = await _firestoreDatasource.createOrGet(
      uid,
      email: email,
      role: role,
      displayName: displayName,
      phone: phone,
    );
    await _sessionService.saveRole(profile.role);
    _logger.debug('AuthRepository: new user profile persisted uid=$uid');

    // For admin sign-ups, atomically create the organization document and link
    // it to the user profile via organizationId.
    if (role == UserRole.admin) {
      _logger.info(
        'AuthRepository: creating organization for new admin uid=$uid',
      );
      final orgResult = await _adminOrganizationRepository.createOrganization(
        adminUid: uid,
        name: orgName ?? '',
      );
      switch (orgResult) {
        case Success(:final data):
          _logger.info('AuthRepository: org created orgId=${data.id} uid=$uid');
          return UserEntity(
            uid: profile.uid,
            email: profile.email,
            role: profile.role,
            displayName: profile.displayName,
            phone: profile.phone,
            organizationId: data.id,
            tutorialCompleted: profile.tutorialCompleted,
          );
        case Failure(:final exception):
          _logger.warning(
            'AuthRepository: org creation failed uid=$uid — '
            '${exception.message}',
            exception,
          );
          // Return profile without organizationId; the missing-org guard will
          // redirect the admin to the setup screen on next navigation.
          return profile;
      }
    }

    return profile;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    _logger.info('AuthRepository: signInWithGoogle');
    final credential = await _authDatasource.signInWithGoogle();
    final user = credential.user!;
    final profile = await _firestoreDatasource.createOrGet(
      user.uid,
      email: user.email,
      role: UserRole.customer,
      displayName: user.displayName,
    );
    await _sessionService.saveRole(profile.role);
    _logger.debug(
      'AuthRepository: Google sign-in complete uid=${user.uid} role=${profile.role.name}',
    );
    return profile;
  }

  @override
  Future<void> signOut() async {
    _logger.info('AuthRepository: signOut');
    await _authDatasource.signOut();
    await _sessionService.clearRole();
    _logger.debug('AuthRepository: session cleared');
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    _logger.info('AuthRepository: sendPasswordResetEmail → $email');
    await _authDatasource.sendPasswordResetEmail(email: email);
    _logger.debug('AuthRepository: password reset email sent');
  }
}
