// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:chat_app/model/audio_model.dart';
import 'package:chat_app/model/file_model.dart';
import 'package:chat_app/model/message_model.dart';
import 'package:chat_app/providers/audio_provider.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

class PreviewContent extends StatelessWidget {
  final dynamic item;

  const PreviewContent({super.key, required this.item});

  Future<void> _openFile(String fileName, String fileContent) async {
    try {
      final decodedBytes = base64Decode(fileContent);
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(decodedBytes);
      await OpenFilex.open(filePath);
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  Future<void> _playAudioFromContent(String audioContent) async {
    try {
      final bytes = base64Decode(audioContent);

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_audio.aac');
      await tempFile.writeAsBytes(bytes);

      final AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.play(DeviceFileSource(tempFile.path));
      print('Playing audio from content.');
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMessage = item is Message;
    final isFileCustom = item is FileCustom;
    final isAudioMessage = item is AudioMessage;
    final audioProvider =
        Provider.of<AudioRecorderProvider>(context, listen: false);
    if (isMessage) {
      return Text(
        item.content,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      );
    } else if (isAudioMessage) {
      return Column(
        children: [
          IconButton(
            icon: Icon(
              Icons.audiotrack,
              color: Colors.blueAccent,
              size: 40,
            ),
            onPressed: () => audioProvider.playAudio(item.audioContent),
          ),
        ],
      );
    } else if (isFileCustom) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openFile(item.fileName, item.fileContent),
          child: (item.fileName.endsWith(".jpg") ||
                  item.fileName.endsWith(".jpeg") ||
                  item.fileName.endsWith(".png"))
              ? Image.memory(
                  base64Decode(item.fileContent),
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                )
              : (item.fileName.endsWith('.pdf'))
                  ? Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 40,
                            color: const Color.fromARGB(255, 117, 38, 32),
                          ),
                          Text(
                            item.fileName,
                            style: TextStyle(color: Colors.lightBlue[200]),
                          ),
                        ],
                      ),
                    )
                  : (item.fileName.endsWith('.docx'))
                      ? Container(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.description,
                                size: 40,
                                color: Color.fromARGB(255, 6, 71, 124),
                              ),
                              Text(
                                item.fileName,
                                style: TextStyle(color: Colors.lightBlue[200]),
                              ),
                            ],
                          ),
                        )
                      : Text(
                          '[File: ${item.fileName}]',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
        ),
      );
    } else {
      return Text(
        '[Unsupported Item]',
        style: TextStyle(color: Colors.red),
      );
    }
  }
}
