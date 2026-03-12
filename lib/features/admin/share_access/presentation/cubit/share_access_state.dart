import 'package:equatable/equatable.dart';

sealed class ShareAccessState extends Equatable {
  const ShareAccessState();
}

final class ShareAccessInitial extends ShareAccessState {
  const ShareAccessInitial();

  @override
  List<Object?> get props => [];
}

final class ShareAccessLinkCopied extends ShareAccessState {
  const ShareAccessLinkCopied();

  @override
  List<Object?> get props => [];
}

final class ShareAccessDownloading extends ShareAccessState {
  const ShareAccessDownloading();

  @override
  List<Object?> get props => [];
}

final class ShareAccessDownloaded extends ShareAccessState {
  const ShareAccessDownloaded();

  @override
  List<Object?> get props => [];
}

final class ShareAccessError extends ShareAccessState {
  const ShareAccessError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
