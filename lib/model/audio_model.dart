import 'package:chat_app/model/chat_item.dart';

class AudioMessage extends ChatItem {
  final String messageId;
  final String senderUsername;
  final String recipientUsername;
  final String audioPath;
  final String audioContent;
  final String duration;
  final String timestamp;
  bool isRead;
  final bool isSent;

  AudioMessage({
    required this.messageId,
    required this.senderUsername,
    required this.recipientUsername,
    required this.audioPath,
    required this.audioContent,
    required this.duration,
    required this.timestamp,
    required this.isRead,
    required this.isSent,
  });
}
