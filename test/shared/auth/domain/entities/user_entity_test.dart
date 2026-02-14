import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/shared/auth/domain/entities/user_entity.dart';
import 'package:queue_ease/shared/auth/domain/entities/user_role.dart';

void main() {
  group('UserEntity', () {
    test('supports value equality', () {
      const user1 = UserEntity(
        uid: '123',
        email: 'test@example.com',
        role: UserRole.admin,
      );
      const user2 = UserEntity(
        uid: '123',
        email: 'test@example.com',
        role: UserRole.admin,
      );

      expect(user1, equals(user2));
    });

    test('different uid produces inequality', () {
      const user1 = UserEntity(
        uid: '123',
        email: 'test@example.com',
        role: UserRole.admin,
      );
      const user2 = UserEntity(
        uid: '456',
        email: 'test@example.com',
        role: UserRole.admin,
      );

      expect(user1, isNot(equals(user2)));
    });

    test('different role produces inequality', () {
      const user1 = UserEntity(
        uid: '123',
        email: 'test@example.com',
        role: UserRole.admin,
      );
      const user2 = UserEntity(
        uid: '123',
        email: 'test@example.com',
        role: UserRole.customer,
      );

      expect(user1, isNot(equals(user2)));
    });
  });

  group('UserRole', () {
    test('has admin and customer values', () {
      expect(UserRole.values, containsAll([UserRole.admin, UserRole.customer]));
      expect(UserRole.values.length, 2);
    });
  });
}
