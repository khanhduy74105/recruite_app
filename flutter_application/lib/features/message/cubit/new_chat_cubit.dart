import 'package:bloc/bloc.dart';
import 'package:flutter_application/models/user_models.dart';
import 'package:flutter_application/features/message/repository/message_repository.dart';
import 'package:meta/meta.dart';
import 'new_chat_common_state.dart';

part 'new_chat_state.dart';

class NewChatCubit extends Cubit<NewChatCommonState> {
  final MessageRepository messageRepository = MessageRepository();

  NewChatCubit() : super(NewChatInitial());

  Future<void> loadConnectedUsers() async {
    try {
      emit(NewChatLoading());
      final users = await messageRepository.getUsers();
      emit(ConnectedUsersLoaded(users: users));
    } catch (e) {
      emit(NewChatError(message: 'Failed to load connected users: $e'));
    }
  }
}