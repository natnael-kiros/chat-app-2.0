import 'dart:collection';
import 'dart:convert';
import 'package:chat_app/model/message_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class MessageProvider with ChangeNotifier {
  final List<Message> _messages = [];

  UnmodifiableListView<Message> get messages => UnmodifiableListView(_messages);

  void addMessage(Map<String, dynamic> messageData) {
    final Message message = Message(
      messageId: messageData['messageId'],
      senderUsername: messageData['senderUsername'],
      recipientUsername: messageData['recipientUsername'],
      content: messageData['content'],
      timestamp: messageData['timestamp'],
      isRead: messageData['isRead'],
      isSent: messageData['isSent'],
    );

    _messages.add(message);
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void markMessagesAsRead(String contactUsername, loggedInUsername) {
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].recipientUsername == loggedInUsername &&
          _messages[i].senderUsername == contactUsername) {
        _messages[i].isRead = true;
      }
    }
    updateMessageReadStatus(loggedInUsername, contactUsername);
    notifyListeners();
  }

  void deleteMessage(String messageId) {
    _messages.removeWhere((message) => message.messageId == messageId);
    notifyListeners();
  }

  void updateMessageReadStatus(String username, String contactUsername) async {
    try {
      final url = Uri.parse('http://192.168.137.50:8080/update-message');
      final response = await http.post(
        url,
        body: jsonEncode(
            {'username': username, 'contactUsername': contactUsername}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Message read status updated successfully');
      } else {
        print('Failed to update message read status');
      }
    } catch (e) {
      print('Error updating message read status: $e');
    }
  }

  List<Map<String, dynamic>> getAllMessagesForUser(String username) {
    final messageUser = _messages
        .where((message) =>
            message.senderUsername == username ||
            message.recipientUsername == username)
        .map((message) => {
              'messageId': message.messageId,
              'senderUsername': message.senderUsername,
              'recipientUsername': message.recipientUsername,
              'content': message.content,
              'timestamp': message.timestamp,
              'isRead': message.isRead,
              'isSent': message.isSent,
            })
        .toList();
    print('DEBUG: Messages for user $username: $messageUser');
    return messageUser;
  }
}
