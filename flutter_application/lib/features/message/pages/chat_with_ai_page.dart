import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/core/constants/env.dart';
import 'package:intl/intl.dart';

class ChatWithAIPage extends StatefulWidget {
  const ChatWithAIPage({Key? key}) : super(key: key);

  @override
  _ChatWithAIPageState createState() => _ChatWithAIPageState();
}

class _ChatWithAIPageState extends State<ChatWithAIPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final List<Map<String, dynamic>> _messages = []; // Local state for messages

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<String> _fetchAIResponse(String question) async {
    try {
      final response = await Dio().post(
        '${Env.beUrl}/bot_chat',
        data: jsonEncode({
          "message": question,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['response'];
      } else {
        return "Something went wrong. Please try again later.";
      }
    } catch (e) {
      return "Something went wrong. Please try again later.";
    }
  }

  void _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isNotEmpty) {
      setState(() {
        _messages.add({
          'content': content,
          'isByMe': true,
          'timestamp': DateTime.now(),
        });
      });
      _controller.clear();
      _focusNode.requestFocus();
      _scrollToBottom();

      // Add a temporary loading message
      setState(() {
        _messages.add({
          'content': "Loading...",
          'isByMe': false,
          'timestamp': DateTime.now(),
        });
      });
      _scrollToBottom();

      String text = await _fetchAIResponse(content);

      // Remove the loading message and add the actual response
      print(text);
      _messages.removeLast();
      _messages.add({
        'content': text,
        'isByMe': false,
        'timestamp': DateTime.now(),
      });
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (timestamp.year == now.year) {
      return DateFormat('dd MMM, HH:mm').format(timestamp);
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Row(
          children: [
            Image.asset(
              'assets/ic_bot.png',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              "Chat with AI",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isByMe = message['isByMe'] as bool;
                final timestamp =
                    _formatTimestamp(message['timestamp'] as DateTime);

                return _ChattingTile(
                  isByMe: isByMe,
                  message: message['content'] as String,
                  timestamp: timestamp,
                  isRead: true, // AI messages are always "read"
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 100),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: "Ask something...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChattingTile extends StatelessWidget {
  final bool isByMe;
  final String message;
  final String timestamp;
  final bool isRead;

  const _ChattingTile({
    required this.isByMe,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: isByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isByMe
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xfff2f2f2),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isByMe
                    ? const Radius.circular(20)
                    : const Radius.circular(4),
                bottomRight: isByMe
                    ? const Radius.circular(4)
                    : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isByMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              timestamp,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
