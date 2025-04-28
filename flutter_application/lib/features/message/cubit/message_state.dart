part of 'message_cubit.dart';

@immutable
sealed class MessageState extends MessageCommonState {}

final class ChatListLoaded extends MessageState {
  final List<ConversationModel> chats;

  ChatListLoaded({required this.chats});
}

final class ConnectedUsersLoaded extends MessageState {
  final List<UserModel> users;

  ConnectedUsersLoaded({required this.users});
}