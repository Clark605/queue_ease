import 'package:equatable/equatable.dart';

/// Represents an organization in the QueueEase system.
///
/// Each organization is owned by an admin user and can manage multiple
/// services, working hours, and appointments.
class OrganizationEntity extends Equatable {
  const OrganizationEntity({
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

  /// Unique identifier for the organization.
  final String id;

  /// Organization name.
  final String name;

  /// Firebase Auth UID of the organization owner.
  final String adminUid;

  /// Unique slug for booking link (e.g., "clinic-123" for queueease.com/clinic-123).
  final String bookingLinkSlug;

  /// URL to the generated QR code for this organization.
  final String? qrCodeUrl;

  /// Physical address of the organization.
  final String? address;

  /// Live open/closed status of the organization.
  final bool isOpen;

  /// URL to the organization logo.
  final String? logoUrl;

  /// Description of the organization.
  final String? description;

  /// Timestamp when the organization was created.
  final DateTime createdAt;

  /// Returns a copy of this entity with the given fields replaced.
  ///
  /// The immutable fields [id], [adminUid], [bookingLinkSlug], and [createdAt]
  /// are intentionally excluded — they cannot be changed after creation.
  /// Nullable optional fields are only replaced when a non-null value is
  /// provided.
  OrganizationEntity copyWith({
    String? name,
    bool? isOpen,
    String? address,
    String? logoUrl,
    String? description,
    String? qrCodeUrl,
  }) {
    return OrganizationEntity(
      id: id,
      name: name ?? this.name,
      adminUid: adminUid,
      bookingLinkSlug: bookingLinkSlug,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    adminUid,
    bookingLinkSlug,
    qrCodeUrl,
    address,
    isOpen,
    logoUrl,
    description,
    createdAt,
  ];
}
