import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/utils/app_logger.dart';
import 'queue_management_state.dart';

/// Manages admin queue state for the queue management UI.
///
/// Use case dependencies and method implementations are added in Phase 3 (T016).
@injectable
class QueueManagementCubit extends Cubit<QueueManagementState> {
  QueueManagementCubit(this._logger) : super(const QueueManagementInitial());

  final AppLogger _logger;

  // TODO(T016): Inject and wire use cases (Phase 3):
  //   - WatchDailyQueueUseCase
  //   - AdvanceQueueUseCase
  //   - SkipQueueEntryUseCase
  //   - MarkNoShowUseCase
  //   - RejoinSkippedUseCase
}
