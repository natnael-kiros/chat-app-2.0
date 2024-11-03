import 'package:hive/hive.dart';

part 'file_model.g.dart';

@HiveType(typeId: 0)
class FileCustom extends HiveObject {
  @HiveField(0)
  final String fileId;
  @HiveField(1)
  final String senderUsername;
  @HiveField(2)
  final String recipientUsername;
  @HiveField(3)
  final String fileName;
  @HiveField(4)
  final String fileContent;
  @HiveField(5)
  final String timestamp;
  @HiveField(6)
  final bool isRead;
  @HiveField(7)
  final bool isSent;

  FileCustom({
    required this.fileId,
    required this.senderUsername,
    required this.recipientUsername,
    required this.fileName,
    required this.fileContent,
    required this.timestamp,
    required this.isRead,
    required this.isSent,
  });
}
