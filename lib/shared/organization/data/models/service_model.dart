import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/service_entity.dart';

/// Data model for [ServiceEntity] with Firestore serialization.
class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.durationMinutes,
    required this.timeMarginMinutes,
    required this.isActive,
    required this.createdAt,
    this.price,
    this.queueType,
    this.description,
  });

  final String id;
  final String orgId;
  final String name;
  final int durationMinutes;
  final int timeMarginMinutes;
  final bool isActive;
  final DateTime createdAt;
  final double? price;
  final String? queueType;
  final String? description;

  /// Creates a [ServiceModel] from a Firestore document.
  ///
  /// The [orgId] parameter is required since services are stored in a
  /// subcollection and the parent org ID is not in the document itself.
  factory ServiceModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String orgId,
  }) {
    assert(
      doc.exists,
      'ServiceModel.fromDoc: document ${doc.id} does not exist',
    );
    final data = doc.data()!;

    final name = data['name'] as String?;
    if (name == null || name.isEmpty) {
      throw FormatException(
        'Service document "${doc.id}" is missing required field "name".',
      );
    }

    final durationMinutes = data['durationMinutes'] as int?;
    if (durationMinutes == null || durationMinutes <= 0) {
      throw FormatException(
        'Service document "${doc.id}" has invalid "durationMinutes": $durationMinutes.',
      );
    }

    return ServiceModel(
      id: doc.id,
      orgId: orgId,
      name: name,
      durationMinutes: durationMinutes,
      timeMarginMinutes: data['timeMarginMinutes'] as int? ?? 5,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      price: (data['price'] as num?)?.toDouble(),
      queueType: data['queueType'] as String?,
      description: data['description'] as String?,
    );
  }

  /// Converts this model to a Firestore map.
  ///
  /// [orgId] is intentionally excluded — it is already encoded in the
  /// subcollection path (`organizations/{orgId}/services`) and storing it
  /// redundantly in the document wastes space.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'durationMinutes': durationMinutes,
      'timeMarginMinutes': timeMarginMinutes,
      'isActive': isActive,
      'price': price,
      'queueType': queueType,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Converts this model to a domain [ServiceEntity].
  ServiceEntity toEntity() => ServiceEntity(
    id: id,
    orgId: orgId,
    name: name,
    durationMinutes: durationMinutes,
    timeMarginMinutes: timeMarginMinutes,
    isActive: isActive,
    createdAt: createdAt,
    price: price,
    queueType: queueType,
    description: description,
  );
}
