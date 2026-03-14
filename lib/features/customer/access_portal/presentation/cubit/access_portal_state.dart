import 'package:equatable/equatable.dart';

sealed class AccessPortalState extends Equatable {
  const AccessPortalState();
  @override
  List<Object?> get props => [];
}

final class AccessPortalScanning extends AccessPortalState {
  const AccessPortalScanning();
}

final class AccessPortalResolving extends AccessPortalState {
  const AccessPortalResolving();
}

final class AccessPortalError extends AccessPortalState {
  const AccessPortalError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}

final class AccessPortalSuccess extends AccessPortalState {
  const AccessPortalSuccess({required this.slug});
  final String slug;
  @override
  List<Object?> get props => [slug];
}
