import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/organization_entity.dart';

/// Mapper class for converting between [OrganizationEntity] and Firestore documents.
class OrganizationModel {
  /// Converts a Firestore document to an [OrganizationEntity].
  static OrganizationEntity fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return OrganizationEntity(
      id: doc.id,
      name: data['name'] as String? ?? '',
      adminUid: data['adminUid'] as String? ?? '',
      bookingLinkSlug: data['bookingLinkSlug'] as String? ?? '',
      isOpen: data['isOpen'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      qrCodeUrl: data['qrCodeUrl'] as String?,
      address: data['address'] as String?,
      logoUrl: data['logoUrl'] as String?,
      description: data['description'] as String?,
    );
  }

  /// Converts an [OrganizationEntity] to a Firestore map.
  static Map<String, dynamic> toMap(OrganizationEntity entity) {
    return {
      'name': entity.name,
      'adminUid': entity.adminUid,
      'bookingLinkSlug': entity.bookingLinkSlug,
      'qrCodeUrl': entity.qrCodeUrl,
      'address': entity.address,
      'isOpen': entity.isOpen,
      'logoUrl': entity.logoUrl,
      'description': entity.description,
      'createdAt': Timestamp.fromDate(entity.createdAt),
    };
  }
}
