import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/utils/app_logger.dart';
import 'customer_queue_status_state.dart';

/// Manages live queue status for the customer home screen.
///
/// Watches the customer's position, turn indicator, and wait estimate.
/// Use case dependencies and method implementations are added in Phase 4 (T024).
@injectable
class CustomerQueueStatusCubit extends Cubit<CustomerQueueStatusState> {
  CustomerQueueStatusCubit(this._logger)
    : super(const CustomerQueueStatusInitial());

  final AppLogger _logger;

  // TODO(T024): Inject and wire WatchCustomerQueueStatusUseCase (Phase 4).
}
