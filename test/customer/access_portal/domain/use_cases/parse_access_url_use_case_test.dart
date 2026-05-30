import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/customer/access_portal/domain/use_cases/parse_access_url_use_case.dart';

void main() {
  late ParseAccessUrlUseCase useCase;

  setUp(() {
    useCase = ParseAccessUrlUseCase();
  });

  group('ParseAccessUrlUseCase', () {
    test('lowercases mixed-case slug from full URL', () {
      // Arrange
      final rawValue = 'https://example.com/c/org/AbC-DeF';

      // Act
      final result = useCase.call(rawValue);

      // Assert: slug should be lowercased
      expect(result.isSuccess, true);
      final success = result as Success<String>;
      expect(success.data, equals('abc-def'));
    });

    test('lowercases mixed-case plain slug', () {
      // Arrange
      final rawValue = 'AbC-DeF';

      // Act
      final result = useCase.call(rawValue);

      // Assert
      expect(result.isSuccess, true);
      final success = result as Success<String>;
      expect(success.data, equals('abc-def'));
    });

    test('lowercases from alternative URL format', () {
      // Arrange
      final rawValue = 'https://example.com/org/XyZ_123';

      // Act
      final result = useCase.call(rawValue);

      // Assert
      expect(result.isSuccess, true);
      final success = result as Success<String>;
      expect(success.data, equals('xyz_123'));
    });

    test('returns failure for invalid slug with spaces', () {
      // Arrange
      final rawValue = 'invalid slug with spaces';

      // Act
      final result = useCase.call(rawValue);

      // Assert: should be a Failure
      expect(result.isFailure, true);
      expect(result, isA<Failure<String>>());
    });

    test('returns failure for empty slug', () {
      // Arrange
      final rawValue = '';

      // Act
      final result = useCase.call(rawValue);

      // Assert
      expect(result.isFailure, true);
    });
  });
}
