import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/core/error/app_exception.dart';
import 'package:queue_ease/core/error/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('isSuccess returns true, isFailure returns false', () {
        const result = Success(42);
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('getOrNull returns the data', () {
        const result = Success('hello');
        expect(result.getOrNull(), 'hello');
      });

      test('getOrElse returns the data, ignores fallback', () {
        const result = Success(10);
        expect(result.getOrElse(99), 10);
      });

      test('map transforms the value', () {
        const result = Success(3);
        final mapped = result.map((v) => v * 2);
        expect(mapped, isA<Success<int>>());
        expect((mapped as Success<int>).data, 6);
      });

      test('when calls success branch', () {
        const result = Success('data');
        final output = result.when(
          success: (d) => 'got $d',
          failure: (_) => 'failed',
        );
        expect(output, 'got data');
      });

      test('toString contains data', () {
        const result = Success(7);
        expect(result.toString(), contains('7'));
      });
    });

    group('Failure', () {
      const exception = DatabaseException('db error');

      test('isFailure returns true, isSuccess returns false', () {
        const result = Failure<int>(exception);
        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('getOrNull returns null', () {
        const result = Failure<String>(exception);
        expect(result.getOrNull(), isNull);
      });

      test('getOrElse returns the fallback', () {
        const result = Failure<int>(exception);
        expect(result.getOrElse(99), 99);
      });

      test('map preserves the exception', () {
        const result = Failure<int>(exception);
        final mapped = result.map((v) => v * 2);
        expect(mapped, isA<Failure<int>>());
        expect((mapped as Failure<int>).exception, exception);
      });

      test('when calls failure branch', () {
        const result = Failure<int>(exception);
        final output = result.when(
          success: (_) => 'ok',
          failure: (e) => 'error: ${e.message}',
        );
        expect(output, 'error: db error');
      });

      test('toString contains exception info', () {
        const result = Failure<int>(exception);
        expect(result.toString(), contains('db error'));
      });
    });

    group('Result.guard', () {
      test('wraps successful async call in Success', () async {
        final result = await Result.guard<int>(() async => 42);
        expect(result, isA<Success<int>>());
        expect((result as Success<int>).data, 42);
      });

      test('wraps thrown AppException in Failure', () async {
        const exception = AuthException('bad creds');
        final result = await Result.guard<int>(() async => throw exception);
        expect(result, isA<Failure<int>>());
        expect((result as Failure<int>).exception, exception);
      });

      test('wraps unknown exceptions in UnknownException', () async {
        final result = await Result.guard<int>(
          () async => throw Exception('unexpected'),
        );
        expect(result, isA<Failure<int>>());
        final failure = result as Failure<int>;
        expect(failure.exception, isA<UnknownException>());
        expect((failure.exception as UnknownException).cause, isA<Exception>());
      });
    });
  });
}
