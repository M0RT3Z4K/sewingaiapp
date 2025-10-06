import 'dart:io';

import 'package:sewingaiapp/features/auth/domain/entities/user.dart';
import 'package:sewingaiapp/features/chat/domain/entities/message.dart';

abstract class ChatRepository {
  Future<Message> sendMessage(String prompt, List lastMessages);
  Future<Message> sendImgMessage(String prompt, List lastMessages, File image);
  Future<User> getCurrentUser();

  Future<List<Message>> getHistory();
}
