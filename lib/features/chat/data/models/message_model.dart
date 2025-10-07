import 'package:sewingaiapp/features/chat/domain/entities/message.dart';

// lib/features/chat/data/models/message_model.dart
class MessageModel extends Message {
  const MessageModel({
    required String id,
    required String text,
    required DateTime createdAt,
    required bool isFromUser,
    required bool isLoading,
    bool isWelcomeMessage = false,
    bool hasButtons = false,
  }) : super(
         id: id,
         text: text,
         createdAt: createdAt,
         isFromUser: isFromUser,
         isLoading: isLoading,
         isWelcomeMessage: isWelcomeMessage,
         hasButtons: hasButtons,
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
      isWelcomeMessage: json['isWelcomeMessage'] ?? false,
      hasButtons: json['hasButtons'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'isFromUser': isFromUser,
      'isWelcomeMessage': isWelcomeMessage,
      'hasButtons': hasButtons,
    };
  }
}
