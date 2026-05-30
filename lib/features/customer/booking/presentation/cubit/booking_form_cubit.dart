import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/app_exception.dart';
import '../../../../../core/error/result.dart';
import '../../../../../core/utils/app_logger.dart';
import '../../domain/use_cases/create_booking_use_case.dart';
import 'booking_form_state.dart';

/// Manages state for the booking confirmation form.
///
/// Call [init] from the route builder to seed the cubit with the booking
/// context (orgId, serviceId, scheduledAt, customerId, prefillName).
///
/// Stores the last-submitted name and phone so [retrySubmit] can re-use them
/// without requiring access to the (still-mounted) TextFormField controllers.
@injectable
class BookingFormCubit extends Cubit<BookingFormState> {
  BookingFormCubit(this._createBookingUseCase, this._logger)
    : super(const BookingFormInitial(prefillName: ''));

  final CreateBookingUseCase _createBookingUseCase;
  final AppLogger _logger;

  late String _orgId;
  late String _serviceId;
  late DateTime _scheduledAt;
  late String _customerId;

  String _lastCustomerName = '';
  String? _lastCustomerPhone;

  void init({
    required String orgId,
    required String serviceId,
    required DateTime scheduledAt,
    required String customerId,
    required String prefillName,
  }) {
    _orgId = orgId;
    _serviceId = serviceId;
    _scheduledAt = scheduledAt;
    _customerId = customerId;
    _logger.debug(
      'BookingFormCubit: init orgId=$orgId serviceId=$serviceId '
      'scheduledAt=${scheduledAt.toIso8601String()} customerId=$customerId',
    );
    emit(BookingFormInitial(prefillName: prefillName));
  }

  Future<void> submitBooking({
    required String customerName,
    String? customerPhone,
  }) async {
    _lastCustomerName = customerName;
    _lastCustomerPhone = customerPhone;
    emit(const BookingFormSubmitting());

    final result = await _createBookingUseCase(
      customerId: _customerId,
      orgId: _orgId,
      serviceId: _serviceId,
      customerName: customerName,
      scheduledAt: _scheduledAt,
      customerPhone: customerPhone,
    );

    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(BookingFormSuccess(data));
      case Failure(:final exception)
          when exception is ValidationException && _isSlotConflict(exception):
        emit(BookingFormConflict(exception.message));
      case Failure(:final exception)
          when exception is DatabaseException || exception is UnknownException:
        emit(BookingFormRetryableError(exception.message));
      case Failure(:final exception):
        emit(BookingFormError(exception.message));
    }
  }

  bool _isSlotConflict(ValidationException exception) {
    final message = exception.message.toLowerCase();
    return exception.field == 'scheduledAt' ||
        message.contains('slot') ||
        message.contains('no longer available');
  }

  /// Re-submits the booking using the previously captured name and phone.
  Future<void> retrySubmit() => submitBooking(
    customerName: _lastCustomerName,
    customerPhone: _lastCustomerPhone,
  );
}
