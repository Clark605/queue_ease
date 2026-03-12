// ignore_for_file: unintended_html_in_doc_comment

import 'package:queue_ease/core/error/result.dart';
import 'package:queue_ease/features/shared_domain/entities/appointment_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/organization_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/service_entity.dart';
import 'package:queue_ease/features/shared_domain/entities/working_hours_entity.dart';

/// Use case contracts for the customer booking flow.
///
/// Each use case encapsulates one piece of business logic and is the sole
/// entry point for the presentation layer. Presentation (Cubits) must never
/// call repositories directly.

// ---------------------------------------------------------------------------
// Use Case 1: Resolve Organization by Slug
// ---------------------------------------------------------------------------
/// Input: booking link slug (String)
/// Output: OrganizationEntity (or failure if not found)
///
/// Reads organization by slug from OrganizationRepository.
/// Returns DatabaseException if not found.
abstract class GetOrganizationBySlugUseCase {
  Future<Result<OrganizationEntity>> call(String slug);
}

// ---------------------------------------------------------------------------
// Use Case 2: Get Active Services for Organization
// ---------------------------------------------------------------------------
/// Input: orgId (String)
/// Output: List<ServiceEntity> filtered to isActive == true
///
/// Streams services from ServiceRepository, filters to active only.
abstract class GetActiveServicesUseCase {
  Stream<List<ServiceEntity>> call(String orgId);
}

// ---------------------------------------------------------------------------
// Use Case 3: Calculate Available Time Slots
// ---------------------------------------------------------------------------
/// Inputs:
///   - orgId: String
///   - serviceId: String
///   - date: DateTime (the target booking date)
///   - workingHours: WorkingHoursEntity (for the target day's schedule)
///   - serviceDurationMinutes: int
///   - currentTime: DateTime (for past-slot filtering)
///
/// Output: List<DateTime> — available slot start times
///
/// Pure domain logic (FR-010):
/// 1. Generate candidate slots at durationMinutes intervals from openTime to closeTime
/// 2. Exclude slots overlapping breakStart–breakEnd
/// 3. Fetch existing appointments via AppointmentRepository
/// 4. Exclude slots overlapping existing appointments (status != noShow)
/// 5. Exclude slots in the past (for today)
abstract class CalculateAvailableSlotsUseCase {
  Future<Result<List<DateTime>>> call({
    required String orgId,
    required String serviceId,
    required DateTime date,
    required WorkingHoursEntity workingHours,
    required int serviceDurationMinutes,
    required DateTime currentTime,
  });
}

// ---------------------------------------------------------------------------
// Use Case 4: Create Booking
// ---------------------------------------------------------------------------
/// Inputs:
///   - orgId, serviceId, scheduledAt, customerName, customerPhone (optional)
///   - customerId (from auth)
///
/// Output: AppointmentEntity (the created appointment)
///
/// Delegates to AppointmentRepository.createAppointment which performs
/// a transactional conflict check.
abstract class CreateBookingUseCase {
  Future<Result<AppointmentEntity>> call({
    required String orgId,
    required String serviceId,
    required DateTime scheduledAt,
    required String customerId,
    required String customerName,
    String? customerPhone,
  });
}
