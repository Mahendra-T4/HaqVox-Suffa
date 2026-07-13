// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_ticket_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupportTicketModelAdapter extends TypeAdapter<SupportTicketModel> {
  @override
  final int typeId = 4;

  @override
  SupportTicketModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupportTicketModel(
      ticketId: fields[0] as String,
      subject: fields[1] as String,
      description: fields[2] as String,
      supportType: fields[3] as String,
      status: fields[4] as String,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime?,
      priority: fields[7] as String?,
      assignedTo: fields[8] as String?,
      attachmentUrls: (fields[9] as List).cast<String>(),
      userKey: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SupportTicketModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.ticketId)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.supportType)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.priority)
      ..writeByte(8)
      ..write(obj.assignedTo)
      ..writeByte(9)
      ..write(obj.attachmentUrls)
      ..writeByte(10)
      ..write(obj.userKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportTicketModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
