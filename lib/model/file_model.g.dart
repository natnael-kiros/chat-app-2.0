// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

class FileCustomAdapter extends TypeAdapter<FileCustom> {
  @override
  final int typeId = 0;

  @override
  FileCustom read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileCustom(
      fileId: fields[0] as String,
      senderUsername: fields[1] as String,
      recipientUsername: fields[2] as String,
      fileName: fields[3] as String,
      fileContent: fields[4] as String,
      timestamp: fields[5] as String,
      isRead: fields[6] as bool,
      isSent: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FileCustom obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.fileId)
      ..writeByte(1)
      ..write(obj.senderUsername)
      ..writeByte(2)
      ..write(obj.recipientUsername)
      ..writeByte(3)
      ..write(obj.fileName)
      ..writeByte(4)
      ..write(obj.fileContent)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.isRead)
      ..writeByte(7)
      ..write(obj.isSent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileCustomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
