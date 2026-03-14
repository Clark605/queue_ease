import 'package:queue_ease/core/error/result.dart';

import 'admin_queue_repository.dart';

/// Contract: Domain use cases for queue lifecycle in Sprint 5.

abstract class GenerateDailyQueueUseCase {
  Future<Result<void>> call({required String orgId, required DateTime date});
}

abstract class WatchDailyQueueUseCase {
  Stream<Result<AdminQueueSnapshot>> call({
    required String orgId,
    required DateTime date,
  });
}

abstract class AdvanceQueueUseCase {
  Future<Result<void>> call({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });
}

abstract class SkipQueueEntryUseCase {
  Future<Result<void>> call({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });
}

abstract class MarkNoShowUseCase {
  Future<Result<void>> call({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });
}

abstract class RejoinSkippedUseCase {
  Future<Result<void>> call({
    required String orgId,
    required DateTime date,
    required String appointmentId,
  });
}

abstract class WatchCustomerQueueStatusUseCase {
  Stream<Result<CustomerQueueStatusView>> call({
    required String orgId,
    required String customerId,
    required DateTime date,
  });
}

class CustomerQueueStatusView {
  const CustomerQueueStatusView({
    required this.position,
    required this.estimatedWaitMinutes,
    required this.isCurrentTurn,
    required this.currentServingIndicator,
  });

  final int? position;
  final int? estimatedWaitMinutes;
  final bool isCurrentTurn;
  final int? currentServingIndicator;
}
