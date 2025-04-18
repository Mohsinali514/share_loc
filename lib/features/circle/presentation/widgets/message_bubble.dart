import 'package:flutter/material.dart';
import 'package:share_loc/core/res/colours.dart';
import 'package:share_loc/features/circle/data/models/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.message,
    required this.isMe,
    required this.futureMembers,
    super.key,
  });
  final Message message;
  final bool isMe;
  final Future<List<Map<String, dynamic>>> futureMembers;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureMembers,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final memberList = snapshot.data!;
        final sender = memberList.firstWhere(
          (member) => member['uid'] == message.senderId,
          orElse: () => <String, dynamic>{},
        );

        final profilePic = (sender['profilePic'] is String)
            ? sender['profilePic'] as String
            : '';

        final avatar = CircleAvatar(
          radius: 16,
          backgroundImage:
              profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
          child: profilePic.isEmpty ? const Icon(Icons.person, size: 16) : null,
        );

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[avatar, const SizedBox(width: 8)],
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.mainColor : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'From: ${message.senderName}',
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) ...[const SizedBox(width: 8), avatar],
            ],
          ),
        );
      },
    );
  }
}
