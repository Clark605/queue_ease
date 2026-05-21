import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/organization_entity.dart';

/// Data model for [OrganizationEntity] with Firestore serialization.
class OrganizationModel {
  const OrganizationModel({
    required this.id,
    required this.name,
    required this.adminUid,
    required this.bookingLinkSlug,
    required this.isOpen,
    required this.createdAt,
    this.qrCodeUrl,
    this.address,
    this.logoUrl,
    this.description,
  });

  final String id;
  final String name;
  final String adminUid;
  final String bookingLinkSlug;
  final bool isOpen;
  final DateTime createdAt;
  final String? qrCodeUrl;
  final String? address;
  final String? logoUrl;
  final String? description;

  /// Creates an [OrganizationModel] from a Firestore document.
  factory OrganizationModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final createdAtValue = data['createdAt'];
    final createdAt = switch (createdAtValue) {
      Timestamp() => createdAtValue.toDate(),
      DateTime() => createdAtValue,
      _ => DateTime.fromMillisecondsSinceEpoch(0),
    };

    return OrganizationModel(
      id: doc.id,
      name: data['name'] as String,
      adminUid: data['adminUid'] as String,
      bookingLinkSlug: data['bookingLinkSlug'] as String,
      isOpen: data['isOpen'] as bool? ?? false,
      createdAt: createdAt,
      qrCodeUrl: data['qrCodeUrl'] as String?,
      address: data['address'] as String?,
      logoUrl: data['logoUrl'] as String?,
      description: data['description'] as String?,
    );
  }

  /// Converts this model to a Firestore map.
  ///
  /// Null optional fields are omitted so they never appear in
  /// `request.resource.data.keys()` during security rule evaluation.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'adminUid': adminUid,
      'bookingLinkSlug': bookingLinkSlug,
      'isOpen': isOpen,
      'createdAt': Timestamp.fromDate(createdAt),
      if (qrCodeUrl != null) 'qrCodeUrl': qrCodeUrl,
      if (address != null) 'address': address,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (description != null) 'description': description,
    };
  }

  /// Converts this model to a domain [OrganizationEntity].
  OrganizationEntity toEntity() => OrganizationEntity(
    id: id,
    name: name,
    adminUid: adminUid,
    bookingLinkSlug: bookingLinkSlug,
    isOpen: isOpen,
    createdAt: createdAt,
    qrCodeUrl: qrCodeUrl,
    address: address,
    logoUrl: logoUrl,
    description: description,
  );
}
