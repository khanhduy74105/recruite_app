part of 'message_cubit.dart';

@immutable
sealed class MessageState {}

final class MessageInitial extends MessageState {}

final class ChatBoxOpened extends MessageState {
  final String userName;
  final List<MessageModel> messages;

  ChatBoxOpened({required this.userName, required this.messages});
}
