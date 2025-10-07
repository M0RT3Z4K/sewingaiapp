import 'dart:io';

class Message {
  final String id;
  final String text;
  final DateTime createdAt;
  final bool isFromUser;
  final bool isLoading;
  final String? imageUrl; // عکس از سرور
  final File? imageFile;
  final bool isWelcomeMessage; // اضافه کن
  final bool hasButtons;

  const Message({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.isFromUser,
    required this.isLoading,
    this.imageUrl,
    this.imageFile,
    this.isWelcomeMessage = false, // پیش‌فرض false
    this.hasButtons = false,
  });
}
