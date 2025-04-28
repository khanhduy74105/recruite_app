import 'package:meta/meta.dart';

@immutable
class MessageCommonState {}

final class MessageInitial extends MessageCommonState {}

final class MessageLoading extends MessageCommonState {}

final class MessageError extends MessageCommonState {
  final String message;

  MessageError({required this.message});
}