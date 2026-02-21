import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/service_entity.dart';

/// Mapper class for converting between [ServiceEntity] and Firestore documents.
class ServiceModel {
  /// Converts a Firestore document to a [ServiceEntity].
  ///
  /// The [orgId] parameter is required since services are stored in a
  /// subcollection and the parent org ID is not in the document itself.
  static ServiceEntity fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String orgId,
  }) {
    final data = doc.data()!;
    return ServiceEntity(
      id: doc.id,
      orgId: orgId,
      name: data['name'] as String? ?? '',
      durationMinutes: data['durationMinutes'] as int? ?? 0,
      timeMarginMinutes: data['timeMarginMinutes'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: (data['price'] as num?)?.toDouble(),
      queueType: data['queueType'] as String?,
      description: data['description'] as String?,
    );
  }

  /// Converts a [ServiceEntity] to a Firestore map.
  static Map<String, dynamic> toMap(ServiceEntity entity) {
    return {
      'orgId': entity.orgId,
      'name': entity.name,
      'durationMinutes': entity.durationMinutes,
      'timeMarginMinutes': entity.timeMarginMinutes,
      'isActive': entity.isActive,
      'price': entity.price,
      'queueType': entity.queueType,
      'description': entity.description,
      'createdAt': Timestamp.fromDate(entity.createdAt),
    };
  }
}
