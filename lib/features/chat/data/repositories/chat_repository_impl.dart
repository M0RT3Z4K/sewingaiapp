import 'dart:convert';
import 'dart:io';

import 'package:sewingaiapp/features/auth/domain/entities/user.dart';
import 'package:sewingaiapp/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:sewingaiapp/features/chat/domain/entities/message.dart';
import 'package:sewingaiapp/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<Message> sendMessage(String prompt, List lastMessages) async {
    final messageModel = await remoteDataSource.sendPrompt(
      prompt,
      lastMessages,
    );
    return messageModel;
  }

  @override
  Future<Message> sendImgMessage(
    String prompt,
    List lastMessages,
    File image,
  ) async {
    final imageRead = await image.readAsBytes();
    final imageBase64 = base64Encode(imageRead);
    final messageModel = await remoteDataSource.sendImgPrompt(
      prompt,
      lastMessages,
      imageBase64,
    );
    print(messageModel.toJson());
    return messageModel;
  }

  @override
  Future<List<Message>> getHistory() async {
    return [];
  }

  @override
  Future<User> getCurrentUser() async {
    final user = await remoteDataSource.getCurrentUser();
    return user;
  }
}
