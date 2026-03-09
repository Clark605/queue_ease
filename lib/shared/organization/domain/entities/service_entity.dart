import 'package:equatable/equatable.dart';

/// Represents a service offered by an organization.
///
/// Services define what customers can book appointments for, including
/// duration, pricing, and queue management settings.
class ServiceEntity extends Equatable {
  const ServiceEntity({
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

  /// Unique identifier for the service.
  final String id;

  /// Parent organization ID.
  final String orgId;

  /// Service name.
  final String name;

  /// Duration of the service in minutes.
  final int durationMinutes;

  /// Grace period before marking as no-show (in minutes).
  final int timeMarginMinutes;

  /// Whether this service is currently active for booking.
  final bool isActive;

  /// Optional display price for the service.
  final double? price;

  /// Optional queue type (e.g., "Priority", "Standard").
  final String? queueType;

  /// Description of the service.
  final String? description;

  /// Timestamp when the service was created.
  final DateTime createdAt;

  /// Returns a copy of this entity with the given fields replaced.
  ///
  /// Nullable fields ([price], [queueType], [description]) are only replaced
  /// when a non-null value is provided — they cannot be explicitly cleared via
  /// this method.
  ServiceEntity copyWith({
    String? id,
    String? orgId,
    String? name,
    int? durationMinutes,
    int? timeMarginMinutes,
    bool? isActive,
    DateTime? createdAt,
    double? price,
    String? queueType,
    String? description,
  }) {
    return ServiceEntity(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      timeMarginMinutes: timeMarginMinutes ?? this.timeMarginMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      price: price ?? this.price,
      queueType: queueType ?? this.queueType,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orgId,
    name,
    durationMinutes,
    timeMarginMinutes,
    isActive,
    price,
    queueType,
    description,
    createdAt,
  ];
}
