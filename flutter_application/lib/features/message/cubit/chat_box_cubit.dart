import 'package:bloc/bloc.dart';
import 'package:flutter_application/models/message_model.dart';
import 'package:meta/meta.dart';

import '../repository/message_repository.dart';
import 'message_common_state.dart';

part 'chat_box_state.dart';

class ChatBoxCubit extends Cubit<MessageCommonState> {
  final MessageRepository messageRepository = MessageRepository();
  final Set<String> existingMessageIds = {};

  ChatBoxCubit() : super(MessageInitial());

  Future<void> openChatBox(String userId) async {
    try {
      emit(MessageLoading());
      final messages = await messageRepository.getMessagesForUser(userId);

      existingMessageIds.clear();
      existingMessageIds.addAll(messages.map((m) => m.id));

      await messageRepository.markMessagesAsRead(userId);
      emit(ChatBoxOpened(userId: userId, messages: messages));
      subscribeToMessages(userId);
    } catch (e) {
      emit(MessageError(message: 'Failed to open chat: $e'));
    }
  }

  Future<void> sendMessage(String userId, String content) async {
    try {
      await messageRepository.sendMessage(userId, content);

      final messages = await messageRepository.getMessagesForUser(userId);

      for (var message in messages) {
        existingMessageIds.add(message.id);
      }

      emit(ChatBoxOpened(userId: userId, messages: messages));
    } catch (e) {
      emit(MessageError(message: 'Failed to send message: $e'));
    }
  }

  void subscribeToMessages(String userId) {
    messageRepository.subscribeToMessages(userId, (newMessage) {
      if (state is ChatBoxOpened && (state as ChatBoxOpened).userId == userId) {
        if (!existingMessageIds.contains(newMessage.id)) {
          existingMessageIds.add(newMessage.id);
          final currentState = state as ChatBoxOpened;
          final updatedMessages = List<MessageModel>.from(currentState.messages)
            ..add(newMessage);
          emit(ChatBoxOpened(userId: userId, messages: updatedMessages));
        }
      }
    });
  }
}
