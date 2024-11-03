import 'package:chat_app/model/chat_item.dart';

class Message extends ChatItem {
  final String messageId;
  final String senderUsername;
  final String recipientUsername;
  final String content;
  final String timestamp;
  bool isRead;
  final bool isSent;

  Message({
    required this.messageId,
    required this.senderUsername,
    required this.recipientUsername,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.isSent,
  });
}
