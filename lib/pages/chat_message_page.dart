// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';
import 'package:chat_app/components/preview.dart';
import 'package:chat_app/model/audio_model.dart';
import 'package:chat_app/model/file_model.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/providers/audio_provider.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/file_provider.dart';
import 'package:chat_app/providers/message_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MessagePage extends StatefulWidget {
  MessagePage({Key? key, required this.username, required this.channel})
      : super(key: key);

  final String username;
  final WebSocketChannel channel;

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _message = TextEditingController();
  int selectedMessageIndex = -1;
  File? file;
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  final ScrollController _scrollController = ScrollController();

  Future<String> getTimeFromServer() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.137.50:8080//time'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['time'];
      } else {
        throw Exception('Failed to get time: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get time: $e');
    }
  }

  void sendMessage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final senderUsername = authProvider.loggedInUsername;
    final currentTime = await getTimeFromServer();
    final message = {
      'type': 'message',
      'messageId': generateUniqueId(),
      'senderUsername': senderUsername,
      'recipientUsername': widget.username,
      'content': _message.text,
      'timestamp': currentTime,
      'isSent': true,
      'isRead': false,
    };

    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    messageProvider.addMessage(message);
    widget.channel.sink.add(jsonEncode(message));

    _message.clear();
    FocusScope.of(context).unfocus();
  }

  void deleteMessage(String messageId) {
    final messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    messageProvider.deleteMessage(messageId);

    final deleteData = {
      'type': 'delete',
      'messageId': messageId,
    };

    widget.channel.sink.add(jsonEncode(deleteData));
  }

  Future<void> sendFile(File filetosend) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final senderUsername = authProvider.loggedInUsername;
    final currentTime = await getTimeFromServer();

    final fileName = filetosend.uri.pathSegments.last;

    final bytes = await filetosend.readAsBytes();
    final fileContent = base64Encode(bytes);
    final fileData = {
      'type': 'file',
      'fileId': generateUniqueId(),
      'senderUsername': senderUsername,
      'recipientUsername': widget.username,
      'fileName': fileName,
      'fileContent': fileContent,
      'timestamp': currentTime,
      'isSent': true,
      'isRead': false,
    };

    final fileProvider = Provider.of<FileProvider>(context, listen: false);
    fileProvider.addFile(fileData);
    widget.channel.sink.add(jsonEncode(fileData));
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
      });
      await sendFile(file!);
    }
  }

  String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);
    final fileProvider = Provider.of<FileProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recorderProvider = Provider.of<AudioRecorderProvider>(context);
    String? loggedInUsername = authProvider.loggedInUsername;

    List<Message> filteredMessages = messageProvider
        .getAllMessagesForUser(widget.username)
        .map((map) => Message(
              messageId: map['messageId'],
              senderUsername: map['senderUsername'],
              recipientUsername: map['recipientUsername'],
              content: map['content'],
              timestamp: map['timestamp'],
              isRead: map['isRead'],
              isSent: map['isSent'],
            ))
        .toList();

    List<FileCustom> filteredFiles = fileProvider
        .getAllFilesForUser(widget.username)
        .map((map) => FileCustom(
              fileId: map['fileId'],
              senderUsername: map['senderUsername'],
              recipientUsername: map['recipientUsername'],
              fileName: map['fileName'],
              fileContent: map['fileContent'],
              timestamp: map['timestamp'],
              isRead: map['isRead'],
              isSent: map['isSent'],
            ))
        .toList();
    List<AudioMessage> filteredAudioMessages = recorderProvider
        .getAllAudioMessages()
        .map((audio) => AudioMessage(
              messageId: audio.messageId,
              senderUsername: audio.senderUsername,
              recipientUsername: audio.recipientUsername,
              audioPath: audio.audioPath,
              audioContent: audio.audioContent,
              duration: audio.duration,
              timestamp: audio.timestamp,
              isRead: audio.isRead,
              isSent: audio.isSent,
            ))
        .toList();

    List<dynamic> filteredContent = [
      ...filteredMessages,
      ...filteredFiles,
      ...filteredAudioMessages
    ];
    filteredContent.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    Future<String> getUniqueAudioFilePath() async {
      final Directory directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '${directory.path}/audio_$timestamp.aac';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          widget.username,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 151, 191, 211),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: filteredContent.length,
                itemBuilder: (context, int index) {
                  final item = filteredContent[index];
                  final isMessage = item is Message;
                  final isSentByCurrentUser =
                      item.senderUsername == loggedInUsername;
                  final formattedTime =
                      DateFormat.Hm().format(DateTime.parse(item.timestamp));

                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                        selectedMessageIndex = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 70),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: selectedMessageIndex == index
                                ? Colors.grey.withOpacity(0.5)
                                : Colors.transparent,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Align(
                                alignment: isSentByCurrentUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSentByCurrentUser
                                        ? const Color.fromARGB(
                                            188, 96, 125, 139)
                                        : const Color.fromARGB(
                                            188, 96, 125, 139),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                      bottomLeft: isSentByCurrentUser
                                          ? Radius.circular(12)
                                          : Radius.circular(0),
                                      bottomRight: isSentByCurrentUser
                                          ? Radius.circular(0)
                                          : Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 70, height: 2),
                                      Text(
                                        '  ${item.senderUsername}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isSentByCurrentUser
                                              ? Color.fromARGB(
                                                  255, 21, 204, 218)
                                              : Color.fromARGB(
                                                  255, 44, 216, 130),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      PreviewContent(item: item),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (selectedMessageIndex == index)
                                Positioned(
                                  top: 4,
                                  left: isSentByCurrentUser ? 0 : null,
                                  right: !isSentByCurrentUser ? 0 : null,
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Color.fromARGB(195, 117, 15, 15),
                                    onPressed: () {
                                      if (isMessage) {
                                        deleteMessage(item.messageId);
                                      }
                                      // else {
                                      //   deleteFile(item.fileId);
                                      // }
                                      setState(() {
                                        selectedMessageIndex = -1;
                                      });
                                    },
                                  ),
                                ),
                              Positioned(
                                bottom: -5,
                                right: isSentByCurrentUser ? -60 : null,
                                left: !isSentByCurrentUser ? -60 : null,
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(
                                    'http://192.168.137.50:8080/profile_image/${item.senderUsername}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              color: Colors.blueGrey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      child: IconButton(
                        onPressed: pickFile,
                        icon: Icon(
                          Icons.attach_file,
                          size: 26,
                          color: Color.fromARGB(190, 243, 243, 243),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _message,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Message",
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(
                            color: Color.fromARGB(190, 243, 243, 243),
                            fontSize: 16.0,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () async {
                        final path = await getUniqueAudioFilePath();
                        recorderProvider.startRecording(path);
                      },
                      onLongPressUp: () async {
                        await recorderProvider.stopRecording(
                            loggedInUsername!, widget.username, widget.channel);
                      },
                      child: Container(
                        child: Icon(
                          Icons.mic,
                          size: 26,
                          color: Color.fromARGB(190, 243, 243, 243),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        size: 30,
                        color: Color.fromARGB(190, 243, 243, 243),
                      ),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final formattedTime = DateFormat.Hm().format(dateTime);
    return formattedTime;
  }
}
