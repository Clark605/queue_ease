import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:queue_ease/shared/organization/data/models/working_hours_model.dart';
import 'package:queue_ease/shared/organization/domain/entities/working_hours_entity.dart'; // needed for toEntity() return type

// ignore: subtype_of_sealed_class
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('WorkingHoursModel', () {
    test('fromDoc converts Firestore document to WorkingHoursModel', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('0'); // Monday
      when(() => mockDoc.data()).thenReturn({
        'isOpen': true,
        'openTime': '09:00',
        'closeTime': '17:00',
        'breakStart': '12:00',
        'breakEnd': '13:00',
      });

      final model = WorkingHoursModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.orgId, 'org1');
      expect(model.dayOfWeek, 0);
      expect(model.isOpen, true);
      expect(model.openTime, '09:00');
      expect(model.closeTime, '17:00');
      expect(model.breakStart, '12:00');
      expect(model.breakEnd, '13:00');
    });

    test('fromDoc handles null optional fields', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('0');
      when(
        () => mockDoc.data(),
      ).thenReturn({'isOpen': true, 'openTime': '09:00', 'closeTime': '17:00'});

      final model = WorkingHoursModel.fromDoc(mockDoc, orgId: 'org1');

      expect(model.breakStart, isNull);
      expect(model.breakEnd, isNull);
    });

    test('fromDoc parses dayOfWeek from document ID', () {
      for (int i = 0; i < 7; i++) {
        final mockDoc = MockDocumentSnapshot();
        when(() => mockDoc.id).thenReturn(i.toString());
        when(() => mockDoc.data()).thenReturn({
          'isOpen': true,
          'openTime': '09:00',
          'closeTime': '17:00',
        });

        final model = WorkingHoursModel.fromDoc(mockDoc, orgId: 'org1');

        expect(model.dayOfWeek, i);
      }
    });

    test('toMap converts WorkingHoursModel to Firestore map', () {
      const model = WorkingHoursModel(
        orgId: 'org1',
        dayOfWeek: 0,
        isOpen: true,
        openTime: '09:00',
        closeTime: '17:00',
        breakStart: '12:00',
        breakEnd: '13:00',
      );

      final map = model.toMap();

      expect(map['orgId'], 'org1');
      expect(map['isOpen'], true);
      expect(map['openTime'], '09:00');
      expect(map['closeTime'], '17:00');
      expect(map['breakStart'], '12:00');
      expect(map['breakEnd'], '13:00');
    });

    test('toEntity converts WorkingHoursModel to WorkingHoursEntity', () {
      const model = WorkingHoursModel(
        orgId: 'org1',
        dayOfWeek: 3,
        isOpen: true,
        openTime: '08:00',
        closeTime: '18:00',
        breakStart: '12:00',
        breakEnd: '13:00',
      );

      final entity = model.toEntity();

      expect(entity.orgId, model.orgId);
      expect(entity.dayOfWeek, model.dayOfWeek);
      expect(entity.isOpen, model.isOpen);
      expect(entity.openTime, model.openTime);
      expect(entity.closeTime, model.closeTime);
      expect(entity.breakStart, model.breakStart);
      expect(entity.breakEnd, model.breakEnd);
    });

    test('round-trip conversion preserves data', () {
      final mockDoc = MockDocumentSnapshot();
      when(() => mockDoc.id).thenReturn('0');
      when(() => mockDoc.data()).thenReturn({
        'isOpen': true,
        'openTime': '09:00',
        'closeTime': '17:00',
        'breakStart': '12:00',
        'breakEnd': '13:00',
      });

      final model = WorkingHoursModel.fromDoc(mockDoc, orgId: 'org1');
      final map = model.toMap();

      expect(map['orgId'], model.orgId);
      expect(map['isOpen'], model.isOpen);
      expect(map['openTime'], model.openTime);
      expect(map['closeTime'], model.closeTime);
      expect(map['breakStart'], model.breakStart);
      expect(map['breakEnd'], model.breakEnd);
    });
  });
}
