/// Cubit state contracts for the customer booking flow.
///
/// Each screen in the funnel has a dedicated Cubit with its own state hierarchy.

// ---------------------------------------------------------------------------
// 1. OrganizationLandingCubit States
// ---------------------------------------------------------------------------
// OrganizationLandingInitial    — before slug resolution
// OrganizationLandingLoading    — resolving slug
// OrganizationLandingLoaded     — org found; holds OrganizationEntity + isCurrentlyOpen (bool)
// OrganizationLandingNotFound   — slug unrecognized
// OrganizationLandingError      — unexpected failure

// ---------------------------------------------------------------------------
// 2. ServiceSelectionCubit States
// ---------------------------------------------------------------------------
// ServiceSelectionInitial       — before loading
// ServiceSelectionLoading       — fetching services
// ServiceSelectionLoaded        — active services list (may be empty)
// ServiceSelectionError         — failure

// ---------------------------------------------------------------------------
// 3. SlotPickerCubit States
// ---------------------------------------------------------------------------
// SlotPickerInitial             — date not yet selected
// SlotPickerLoading             — calculating slots for selected date
// SlotPickerLoaded              — available slots for selected date; holds:
//                                  selectedDate, availableSlots (List<DateTime>),
//                                  selectedSlot (DateTime?)
// SlotPickerNoSlots             — selected date has zero available slots
// SlotPickerError               — failure

// ignore_for_file: dangling_library_doc_comments

// ---------------------------------------------------------------------------
// 4. BookingFormCubit States
// ---------------------------------------------------------------------------
// BookingFormInitial            — form ready with pre-filled name
// BookingFormSubmitting         — write in progress
// BookingFormSuccess            — appointment created; holds AppointmentEntity
// BookingFormConflict           — slot taken by another customer
// BookingFormError              — unexpected failure
