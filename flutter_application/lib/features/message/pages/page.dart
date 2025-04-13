import 'package:flutter/material.dart';
import 'package:flutter_application/features/message/cubit/message_cubit.dart';
import 'package:flutter_application/features/message/pages/chat_box_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final messageRepository = context.read<MessageCubit>().messageRepository;
    final users = messageRepository.getUsers()
        .where((user) => user.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search User...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          // User Row
          SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatBoxPage(userName: user),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Text(user[0]), // Display first letter of user
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 60,
                          child: Text(
                            user,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(),
          // Conversation List
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Slidable(
                  key: ValueKey(user),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          setState(() {
                            users.removeAt(index);
                          });
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user[0]), // Display first letter of user
                    ),
                    title: Text(user),
                    subtitle: const Text('Last message preview...'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatBoxPage(userName: user),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
