import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/result.dart';
import '../../domain/use_cases/parse_access_url_use_case.dart';
import 'access_portal_state.dart';

@injectable
class AccessPortalCubit extends Cubit<AccessPortalState> {
  AccessPortalCubit(this._parse) : super(const AccessPortalScanning());

  final ParseAccessUrlUseCase _parse;

  void submitQrCode(String raw) => _resolve(raw);

  void submitUrl(String url) => _resolve(url);

  void reset() => emit(const AccessPortalScanning());

  void _resolve(String value) {
    emit(const AccessPortalResolving());
    final result = _parse(value);
    switch (result) {
      case Success(:final data):
        emit(AccessPortalSuccess(slug: data));
      case Failure(:final exception):
        emit(AccessPortalError(message: exception.message));
    }
  }
}
