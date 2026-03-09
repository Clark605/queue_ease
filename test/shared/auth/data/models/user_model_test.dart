import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/shared/auth/data/models/user_model.dart';
import 'package:queue_ease/shared/auth/domain/entities/user_entity.dart';
import 'package:queue_ease/shared/auth/domain/entities/user_role.dart';

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockFirebaseUser extends Mock implements auth.User {}

void main() {
  group('UserModel', () {
    group('fromFirestore', () {
      test('converts Firestore document to UserModel with all fields', () {
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn({
          'email': 'test@example.com',
          'role': 'admin',
          'displayName': 'Test User',
          'phone': '+1234567890',
          'organizationId': 'org123',
          'tutorialCompleted': true,
        });

        final model = UserModel.fromFirestore(mockDoc);

        expect(model.uid, 'user123');
        expect(model.email, 'test@example.com');
        expect(model.role, UserRole.admin);
        expect(model.displayName, 'Test User');
        expect(model.phone, '+1234567890');
        expect(model.organizationId, 'org123');
        expect(model.tutorialCompleted, true);
      });

      test('handles null optional fields', () {
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('user123');
        when(
          () => mockDoc.data(),
        ).thenReturn({'email': 'test@example.com', 'role': 'customer'});

        final model = UserModel.fromFirestore(mockDoc);

        expect(model.uid, 'user123');
        expect(model.email, 'test@example.com');
        expect(model.role, UserRole.customer);
        expect(model.displayName, isNull);
        expect(model.phone, isNull);
        expect(model.organizationId, isNull);
        expect(model.tutorialCompleted, false);
      });

      test('defaults to customer role for invalid role string', () {
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('user123');
        when(
          () => mockDoc.data(),
        ).thenReturn({'email': 'test@example.com', 'role': 'invalid_role'});

        final model = UserModel.fromFirestore(mockDoc);

        expect(model.role, UserRole.customer);
      });

      test('throws FormatException when document data is null', () {
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn('user123');
        when(() => mockDoc.data()).thenReturn(null);

        expect(
          () => UserModel.fromFirestore(mockDoc),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('fromJson', () {
      test('converts JSON map to UserModel with all fields', () {
        final json = {
          'uid': 'user123',
          'email': 'test@example.com',
          'role': 'admin',
          'displayName': 'Test User',
          'phone': '+1234567890',
          'organizationId': 'org123',
          'tutorialCompleted': true,
        };

        final model = UserModel.fromJson(json);

        expect(model.uid, 'user123');
        expect(model.email, 'test@example.com');
        expect(model.role, UserRole.admin);
        expect(model.displayName, 'Test User');
        expect(model.phone, '+1234567890');
        expect(model.organizationId, 'org123');
        expect(model.tutorialCompleted, true);
      });

      test('uses uid parameter over json uid field', () {
        final json = {
          'uid': 'json_uid',
          'email': 'test@example.com',
          'role': 'customer',
        };

        final model = UserModel.fromJson(json, uid: 'override_uid');

        expect(model.uid, 'override_uid');
      });

      test('handles missing email with empty string', () {
        final json = {'uid': 'user123', 'role': 'customer'};

        final model = UserModel.fromJson(json);

        expect(model.email, '');
      });

      test('handles null role with customer default', () {
        final json = {'uid': 'user123', 'email': 'test@example.com'};

        final model = UserModel.fromJson(json);

        expect(model.role, UserRole.customer);
      });
    });

    group('fromFirebaseUser', () {
      test('converts Firebase Auth User to UserModel', () {
        final mockFbUser = MockFirebaseUser();
        when(() => mockFbUser.uid).thenReturn('user123');
        when(() => mockFbUser.email).thenReturn('test@example.com');
        when(() => mockFbUser.displayName).thenReturn('Test User');

        final model = UserModel.fromFirebaseUser(mockFbUser);

        expect(model.uid, 'user123');
        expect(model.email, 'test@example.com');
        expect(model.role, UserRole.customer);
        expect(model.displayName, 'Test User');
        expect(model.phone, isNull);
      });

      test('uses provided role and phone parameters', () {
        final mockFbUser = MockFirebaseUser();
        when(() => mockFbUser.uid).thenReturn('user123');
        when(() => mockFbUser.email).thenReturn('test@example.com');
        when(() => mockFbUser.displayName).thenReturn('Test User');

        final model = UserModel.fromFirebaseUser(
          mockFbUser,
          role: UserRole.admin,
          phone: '+1234567890',
        );

        expect(model.role, UserRole.admin);
        expect(model.phone, '+1234567890');
      });

      test('handles null Firebase User email', () {
        final mockFbUser = MockFirebaseUser();
        when(() => mockFbUser.uid).thenReturn('user123');
        when(() => mockFbUser.email).thenReturn(null);
        when(() => mockFbUser.displayName).thenReturn(null);

        final model = UserModel.fromFirebaseUser(mockFbUser);

        expect(model.email, '');
        expect(model.displayName, isNull);
      });
    });

    group('toJson', () {
      test('converts UserModel to JSON map with all fields', () {
        const model = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          role: UserRole.admin,
          displayName: 'Test User',
          phone: '+1234567890',
          organizationId: 'org123',
          tutorialCompleted: true,
        );

        final json = model.toJson();

        expect(json['uid'], 'user123');
        expect(json['email'], 'test@example.com');
        expect(json['role'], 'admin');
        expect(json['displayName'], 'Test User');
        expect(json['phone'], '+1234567890');
        expect(json['organizationId'], 'org123');
        expect(json['tutorialCompleted'], true);
      });

      test('includes null values for optional fields', () {
        const model = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          role: UserRole.customer,
        );

        final json = model.toJson();

        expect(json['displayName'], isNull);
        expect(json['phone'], isNull);
        expect(json['organizationId'], isNull);
        expect(json['tutorialCompleted'], false);
      });
    });

    group('toEntity', () {
      test('converts UserModel to UserEntity with all fields', () {
        const model = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          role: UserRole.admin,
          displayName: 'Test User',
          phone: '+1234567890',
          organizationId: 'org123',
          tutorialCompleted: true,
        );

        final entity = model.toEntity();

        expect(entity, isA<UserEntity>());
        expect(entity.uid, 'user123');
        expect(entity.email, 'test@example.com');
        expect(entity.role, UserRole.admin);
        expect(entity.displayName, 'Test User');
        expect(entity.phone, '+1234567890');
        expect(entity.organizationId, 'org123');
        expect(entity.tutorialCompleted, true);
      });

      test('returns separate UserEntity instance', () {
        const model = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          role: UserRole.customer,
        );

        final entity = model.toEntity();

        // Verify it's not the same instance (no longer extending)
        expect(identical(model, entity), false);
        expect(entity, isNot(same(model)));
      });
    });

    group('fromEntity', () {
      test('converts UserEntity to UserModel with all fields', () {
        const entity = UserEntity(
          uid: 'user123',
          email: 'test@example.com',
          role: UserRole.admin,
          displayName: 'Test User',
          phone: '+1234567890',
          organizationId: 'org123',
          tutorialCompleted: true,
        );

        final model = UserModel.fromEntity(entity);

        expect(model.uid, 'user123');
        expect(model.email, 'test@example.com');
        expect(model.role, UserRole.admin);
        expect(model.displayName, 'Test User');
        expect(model.phone, '+1234567890');
        expect(model.organizationId, 'org123');
        expect(model.tutorialCompleted, true);
      });

      test('preserves all entity properties', () {
        const entity = UserEntity(
          uid: 'user123',
          email: 'test@example.com',
          role: UserRole.customer,
        );

        final model = UserModel.fromEntity(entity);

        expect(model.uid, entity.uid);
        expect(model.email, entity.email);
        expect(model.role, entity.role);
        expect(model.displayName, entity.displayName);
        expect(model.phone, entity.phone);
        expect(model.organizationId, entity.organizationId);
        expect(model.tutorialCompleted, entity.tutorialCompleted);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        const original = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          role: UserRole.customer,
          displayName: 'Original Name',
        );

        final updated = original.copyWith(
          displayName: 'Updated Name',
          phone: '+1234567890',
        );

        expect(updated.uid, original.uid);
        expect(updated.email, original.email);
        expect(updated.role, original.role);
        expect(updated.displayName, 'Updated Name');
        expect(updated.phone, '+1234567890');
      });

      test('keeps original values when no parameters provided', () {
        const original = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          role: UserRole.admin,
          displayName: 'Test User',
          organizationId: 'org123',
        );

        final copy = original.copyWith();

        expect(copy.uid, original.uid);
        expect(copy.email, original.email);
        expect(copy.role, original.role);
        expect(copy.displayName, original.displayName);
        expect(copy.organizationId, original.organizationId);
      });
    });

    group('equality', () {
      test('two UserModels with same values are equal', () {
        const model1 = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          role: UserRole.customer,
          displayName: 'Test User',
        );

        const model2 = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          role: UserRole.customer,
          displayName: 'Test User',
        );

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('two UserModels with different values are not equal', () {
        const model1 = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          role: UserRole.customer,
        );

        const model2 = UserModel(
          uid: 'user456',
          email: 'test@example.com',
          role: UserRole.customer,
        );

        expect(model1, isNot(equals(model2)));
      });
    });
  });
}
