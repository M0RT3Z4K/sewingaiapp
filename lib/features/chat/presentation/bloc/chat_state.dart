import 'package:sewingaiapp/features/auth/domain/entities/user.dart';
import 'package:sewingaiapp/features/chat/domain/entities/message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final User user;
  ChatLoaded(this.messages, this.user);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
