import 'package:chat_app/model/file_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FileProvider with ChangeNotifier {
  final List<FileCustom> _files = [];
  late Box<FileCustom> fileBox;

  FileProvider() {
    _initializeHiveBox();
  }

  Future<void> _initializeHiveBox() async {
    fileBox = await Hive.openBox<FileCustom>('fileBox');
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    _files.clear();
    _files.addAll(fileBox.values);
    _files.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    notifyListeners();
  }

  Future<void> addFile(Map<String, dynamic> fileData) async {
    final file = FileCustom(
      fileId: fileData['fileId'],
      senderUsername: fileData['senderUsername'],
      recipientUsername: fileData['recipientUsername'],
      fileName: fileData['fileName'],
      fileContent: fileData['fileContent'],
      timestamp: fileData['timestamp'],
      isRead: fileData['isRead'],
      isSent: fileData['isSent'],
    );

    _files.add(file);
    _files.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    await fileBox.add(file);
    notifyListeners();
  }

  List<Map<String, dynamic>> getAllFilesForUser(String username) {
    return _files
        .where((file) =>
            file.senderUsername == username ||
            file.recipientUsername == username)
        .map((file) => {
              'fileId': file.fileId,
              'senderUsername': file.senderUsername,
              'recipientUsername': file.recipientUsername,
              'fileName': file.fileName,
              'fileContent': file.fileContent,
              'timestamp': file.timestamp,
              'isRead': file.isRead,
              'isSent': file.isSent,
            })
        .toList();
  }
}
