part of 'new_chat_cubit.dart';

@immutable
sealed class NewChatState extends NewChatCommonState {}

final class ConnectedUsersLoaded extends NewChatState {
  final List<UserModel> users;

  ConnectedUsersLoaded({required this.users});
}