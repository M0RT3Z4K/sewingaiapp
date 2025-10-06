import 'package:sewingaiapp/features/chat/domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required String id,
    required String text,
    required DateTime createdAt,
    required bool isFromUser,
    required bool isLoading,
  }) : super(
         id: id,
         text: text,
         createdAt: createdAt,
         isFromUser: isFromUser,
         isLoading: isLoading,
       );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      isFromUser: json['isFromUser'] as bool? ?? false,
      isLoading: json['isLoading'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isFromUser': isFromUser,
    };
  }
}
