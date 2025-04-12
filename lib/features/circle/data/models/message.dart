class Message {
  Message({
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.senderName,
    this.circleId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      circleId: json['circleId'] as String,
      senderName: json['senderName'] as String,
    );
  }
  final String senderId;
  final String content;
  final DateTime timestamp;
  final String? circleId;
  final String senderName;

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'circleId': circleId,
      'senderName': senderName,
    };
  }
}
