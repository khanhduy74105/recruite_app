import 'dart:math';
import '../../../models/message_model.dart';

class MessageRepository {
  final List<String> _users = List.generate(10, (index) => 'User $index');

  List<String> getUsers() {
    return _users;
  }

  List<MessageModel> getMessagesForUser(String userName) {
    // Generate fake messages for the user
    return List.generate(
      5,
      (index) => MessageModel(
        senderId: Random().nextBool() ? userName : 'Me',
        receiverId: Random().nextBool() ? 'Me' : userName,
        content: 'Message $index from $userName',
        sentAt: DateTime.now().subtract(Duration(minutes: index * 5)),
      ),
    );
  }
}
