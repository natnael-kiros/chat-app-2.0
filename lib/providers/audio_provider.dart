import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/model/audio_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class AudioRecorderProvider with ChangeNotifier {
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _audioFilePath;
  List<AudioMessage> _audioMessages = [];
  AudioRecorderProvider() {
    _recorder = FlutterSoundRecorder();
    _init();
  }

  Future<void> _init() async {
    await _recorder!.openAudioSession();
  }

  bool get isRecording => _isRecording;

  Future<void> startRecording(String path) async {
    if (_isRecording) {
      print("Recorder is already running.");
      return;
    }

    if (await Permission.microphone.request().isGranted) {
      _audioFilePath = path;
      await _recorder!.startRecorder(toFile: path);
      _isRecording = true;
      notifyListeners();
    } else {
      print('Microphone permission not granted');
    }
  }

  Future<void> sendAudio(
      AudioMessage audioMessage, WebSocketChannel channel) async {
    final message = {
      'type': 'audio',
      'messageId': audioMessage.messageId,
      'senderUsername': audioMessage.senderUsername,
      'recipientUsername': audioMessage.recipientUsername,
      'audioPath': audioMessage.audioPath,
      'audioContent': audioMessage.audioContent,
      'duration': audioMessage.duration,
      'timestamp': audioMessage.timestamp,
      'isSent': audioMessage.isSent,
      'isRead': audioMessage.isRead,
    };

    channel.sink.add(jsonEncode(message));
  }

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

  Future<AudioMessage?> stopRecording(String senderUsername,
      String recipientUsername, WebSocketChannel channel) async {
    if (_isRecording) {
      await _recorder!.stopRecorder();
      _isRecording = false;
      notifyListeners();

      // After recording is stopped, create an AudioMessage if the file path exists
      if (_audioFilePath != null) {
        int duration = await _getAudioDuration(_audioFilePath!);
        final currentTime = await getTimeFromServer();

        // Read the audio file and convert it to a Base64 string
        File audioFile = File(_audioFilePath!);
        List<int> audioBytes = await audioFile.readAsBytes();
        String audioContent =
            base64Encode(audioBytes); // Convert to Base64 string

        AudioMessage audioMessage = AudioMessage(
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
          senderUsername: senderUsername,
          recipientUsername: recipientUsername,
          audioPath: _audioFilePath!,
          audioContent: audioContent, // Save as a Base64 string
          duration: _formatDuration(duration),
          timestamp: currentTime,
          isRead: false,
          isSent: true,
        );

        // Save the audio message to the _audioMessages list
        _audioMessages.add(audioMessage);
        await sendAudio(audioMessage, channel);
        notifyListeners(); // Notify listeners about the change
        return audioMessage;
      }
    }
    return null;
  }

  Future<int> _getAudioDuration(String path) async {
    // Future implementaionn
    return 30;
  }

  List<AudioMessage> getAllAudioMessages() {
    return _audioMessages;
  }

  // Future<void> playAudio(String filePath) async {
  //   final AudioPlayer audioPlayer = AudioPlayer();
  //   try {
  //     await audioPlayer.play(DeviceFileSource(filePath));
  //   } catch (e) {
  //     print('Error playing audio: $e');
  //   }
  // }

  Future<void> playAudio(String audioContent) async {
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

  void addAudio(Map<String, dynamic> audioData) {
    AudioMessage audioMessage = AudioMessage(
      messageId: audioData['messageId'] ?? '',
      senderUsername: audioData['senderUsername'] ?? '',
      recipientUsername: audioData['recipientUsername'] ?? '',
      audioPath: audioData['audioPath'] ?? '',
      audioContent: audioData['audioContent'] ?? '',
      duration: audioData['duration'] ?? '0:00',
      timestamp: audioData['timestamp'] ?? '',
      isRead: audioData['isRead'] ?? false,
      isSent: audioData['isSent'] ?? true,
    );
    print(audioMessage);
    _audioMessages.add(audioMessage);

    notifyListeners();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _recorder?.closeAudioSession();
    super.dispose();
  }
}
