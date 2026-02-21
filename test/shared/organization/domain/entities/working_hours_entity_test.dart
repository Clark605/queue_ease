import 'package:flutter_test/flutter_test.dart';
import 'package:queue_ease/shared/organization/domain/entities/working_hours_entity.dart';

void main() {
  group('WorkingHoursEntity', () {
    test('supports value equality', () {
      const workingHours1 = WorkingHoursEntity(
        orgId: 'org1',
        dayOfWeek: 0,
        isOpen: true,
        openTime: '09:00',
        closeTime: '17:00',
      );

      const workingHours2 = WorkingHoursEntity(
        orgId: 'org1',
        dayOfWeek: 0,
        isOpen: true,
        openTime: '09:00',
        closeTime: '17:00',
      );

      expect(workingHours1, equals(workingHours2));
    });

    test('different days are not equal', () {
      const workingHours1 = WorkingHoursEntity(
        orgId: 'org1',
        dayOfWeek: 0,
        isOpen: true,
        openTime: '09:00',
        closeTime: '17:00',
      );

      const workingHours2 = WorkingHoursEntity(
        orgId: 'org1',
        dayOfWeek: 1,
        isOpen: true,
        openTime: '09:00',
        closeTime: '17:00',
      );

      expect(workingHours1, isNot(equals(workingHours2)));
    });

    test('different times are not equal', () {
      const workingHours1 = WorkingHoursEntity(
        orgId: 'org1',
        dayOfWeek: 0,
        isOpen: true,
        openTime: '09:00',
        closeTime: '17:00',
      );

      const workingHours2 = WorkingHoursEntity(
        orgId: 'org1',
        dayOfWeek: 0,
        isOpen: true,
        openTime: '08:00',
        closeTime: '17:00',
      );

      expect(workingHours1, isNot(equals(workingHours2)));
    });

    test('nullable fields are included in equality', () {
      const workingHours1 = WorkingHoursEntity(
        orgId: 'org1',
        dayOfWeek: 0,
        isOpen: true,
        openTime: '09:00',
        closeTime: '17:00',
        breakStart: '12:00',
        breakEnd: '13:00',
      );

      const workingHours2 = WorkingHoursEntity(
        orgId: 'org1',
        dayOfWeek: 0,
        isOpen: true,
        openTime: '09:00',
        closeTime: '17:00',
        breakStart: '12:30',
        breakEnd: '13:00',
      );

      expect(workingHours1, isNot(equals(workingHours2)));
    });

    test('props includes all fields', () {
      const workingHours = WorkingHoursEntity(
        orgId: 'org1',
        dayOfWeek: 0,
        isOpen: true,
        openTime: '09:00',
        closeTime: '17:00',
        breakStart: '12:00',
        breakEnd: '13:00',
      );

      expect(workingHours.props, [
        'org1',
        0,
        true,
        '09:00',
        '17:00',
        '12:00',
        '13:00',
      ]);
    });
  });
}
