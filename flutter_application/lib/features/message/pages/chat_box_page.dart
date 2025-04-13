import 'package:flutter/material.dart';
import 'package:flutter_application/features/message/cubit/message_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatBoxPage extends StatelessWidget {
  final String userName;

  const ChatBoxPage({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final messageCubit = context.read<MessageCubit>();
    final messages = messageCubit.messageRepository.getMessagesForUser(userName);

    return Scaffold(
      appBar: AppBar(title: Text('Chat with $userName')),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message.senderId == 'Me'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: message.senderId == 'Me'
                          ? Colors.blueAccent
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message.content ?? '',
                      style: TextStyle(
                        color: message.senderId == 'Me'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Text Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Add logic to send a message
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
