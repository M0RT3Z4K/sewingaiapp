import 'dart:io';

abstract class ChatEvent {}

class SendUserMessage extends ChatEvent {
  final String text;
  SendUserMessage(this.text);
}

class LoadHistory extends ChatEvent {}

class SendImageMessage extends ChatEvent {
  final String text;
  final File image;
  SendImageMessage(this.text, this.image);
}
