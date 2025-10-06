import 'dart:io';

import 'package:sewingaiapp/features/chat/domain/entities/message.dart';
import 'package:sewingaiapp/features/chat/domain/repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;
  final List lastMessages = [];

  SendMessage(this.repository);

  Future<Message> call(String prompt, List lastMessages) async {
    return await repository.sendMessage(prompt, lastMessages);
  }
}

class SendImgMessage {
  final ChatRepository repository;
  final List lastMessages = [];

  SendImgMessage(this.repository);

  Future<Message> call(String prompt, List lastMessages, File image) async {
    return await repository.sendImgMessage(prompt, lastMessages, image);
  }
}
