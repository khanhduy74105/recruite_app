import 'package:bloc/bloc.dart';
import 'package:flutter_application/models/conversation_model.dart';
import 'package:meta/meta.dart';
import '../../../models/user_models.dart';
import '../repository/message_repository.dart';
import 'message_common_state.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageCommonState> {
  final MessageRepository messageRepository = MessageRepository();

  MessageCubit() : super(MessageInitial());

  Future<void> loadChats() async {
    try {
      final chats = await messageRepository.getChats();
      emit(ChatListLoaded(chats: chats));
    } catch (e) {
      emit(MessageError(message: 'Failed to load chats: $e'));
    }
  }
}