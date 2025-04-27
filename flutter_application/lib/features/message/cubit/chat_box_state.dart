part of 'chat_box_cubit.dart';

@immutable
sealed class ChatBoxState extends MessageCommonState {}

final class ChatBoxOpened extends ChatBoxState {
  final String userId;
  final List<MessageModel> messages;

  ChatBoxOpened({required this.userId, required this.messages});
}