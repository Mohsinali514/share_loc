import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/features/circle/data/models/message.dart';
import 'package:share_loc/features/circle/presentation/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  String? circleId;
  late Future<List<Map<String, dynamic>>> futureMembers;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments! as Map;
      setState(() {
        circleId = args['circleId'] as String;
        futureMembers =
            args['futureMembers'] as Future<List<Map<String, dynamic>>>;
      });
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty || circleId == null) return;

    final user = context.read<UserProvider>().user;
    final newMessage = Message(
      senderId: user?.uid ?? '',
      content: text.trim(),
      timestamp: DateTime.now(),
      circleId: circleId,
      senderName: user?.fullName ?? '',
    );

    _textController.clear();
    _sendMessageToCircle(newMessage);
  }

  Future<void> _sendMessageToCircle(Message message) async {
    try {
      await FirebaseFirestore.instance
          .collection('circle_chats')
          .doc(message.circleId)
          .collection('messages')
          .add(message.toJson());
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  Stream<List<Message>> getMessagesStream() {
    return FirebaseFirestore.instance
        .collection('circle_chats')
        .doc(circleId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (circleId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Circle Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    return MessageBubble(
                      message: message,
                      isMe: message.senderId ==
                          context.read<UserProvider>().user?.uid,
                      futureMembers: futureMembers,
                    );
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.grey.shade100,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _sendMessage(_textController.text),
              color: AppColors.mainColor,
            ),
          ],
        ),
      ),
    );
  }
}
