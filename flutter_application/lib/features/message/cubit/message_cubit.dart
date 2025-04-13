import 'package:bloc/bloc.dart';
import 'package:flutter_application/features/message/repository/message_repository.dart';
import 'package:meta/meta.dart';
import '../../../models/message_model.dart';

part 'message_state.dart';

class MessageCubit extends Cubit<MessageState> {
  final MessageRepository messageRepository = MessageRepository();

  MessageCubit() : super(MessageInitial());

  void openChatBox(String userName) {
    final messages = messageRepository.getMessagesForUser(userName);
    emit(ChatBoxOpened(userName: userName, messages: messages));
  }
}
