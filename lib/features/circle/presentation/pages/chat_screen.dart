import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_loc/core/common/providers/user_provider.dart';
import 'package:share_loc/features/circle/data/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  // Or chatroom ID

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  String? circleId;

  @override
  void initState() {
    super.initState();
    // In a real app, load initial messages here:
    // _loadMessages();
  }

  // Example function to simulate sending a message (replace with backend logic)
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final user = context.read<UserProvider>().user;
    final newMessage = Message(
      senderId: user?.uid ?? '',
      content: text,
      timestamp: DateTime.now(),
      circleId: circleId,
      senderName: user?.fullName ?? '',
    );

    setState(_textController.clear);

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
      print('Error sending message: $e');
      // Handle the error appropriately (e.g., show a snackbar)
    }
  }

  Stream<List<Message>> getMessagesForCircle(String circleId) {
    return FirebaseFirestore.instance
        .collection('circle_chats')
        .doc(circleId)
        .collection('messages')
        .orderBy('timestamp') // Order by time sent
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    circleId = ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(title: const Text('Chat for Circle')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: getMessagesForCircle(circleId!),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListTile(
                          tileColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(message.content),
                          subtitle: Text('From: ${message.senderName}'),
                          // Customize message display further (e.g., bubbles, timestamps)
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
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
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration:
                    const InputDecoration(hintText: 'Type a message...'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _sendMessage(_textController.text),
            ),
          ],
        ),
      ),
    );
  }
}
