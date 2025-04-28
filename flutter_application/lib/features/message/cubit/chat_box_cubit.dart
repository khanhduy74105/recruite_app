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

      await messageRepository.markMessagesAsRead(userId);

      final messages = await messageRepository.getMessagesForUser(userId);

      existingMessageIds.clear();
      existingMessageIds.addAll(messages.map((m) => m.id));

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
    messageRepository.subscribeToMessages(userId, (message) {
      if (state is ChatBoxOpened && (state as ChatBoxOpened).userId == userId) {
        final currentState = state as ChatBoxOpened;
        final updatedMessages = List<MessageModel>.from(currentState.messages);

        final existingMessageIndex = updatedMessages.indexWhere((m) => m.id == message.id);
        if (existingMessageIndex != -1) {
          updatedMessages[existingMessageIndex] = message;
        } else if (!existingMessageIds.contains(message.id)) {
          existingMessageIds.add(message.id);
          updatedMessages.add(message);
        }

        emit(ChatBoxOpened(userId: userId, messages: updatedMessages));
      }
    });
  }
}