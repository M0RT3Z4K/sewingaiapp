import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sewingaiapp/features/chat/domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({required this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isFromUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          margin: message.isFromUser
              ? EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.11,
                  4,
                  8,
                  4,
                )
              : EdgeInsets.fromLTRB(
                  8,
                  4,
                  MediaQuery.of(context).size.width * 0.11,
                  4,
                ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isFromUser
                ? Colors.blueAccent
                : Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: message.isFromUser
                  ? const Radius.circular(12)
                  : Radius.zero,
              bottomRight: message.isFromUser
                  ? Radius.zero
                  : const Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              message.isLoading
                  ? LoadingAnimationWidget.progressiveDots(
                      color: Colors.blue,
                      size: 27,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.imageFile != null)
                          Image.file(message.imageFile!, height: 200),
                        if (message.imageUrl != null)
                          Image.network(message.imageUrl!, width: 200),
                        SizedBox(height: 10),
                        Text(
                          message.text,
                          style: TextStyle(
                            color: message.isFromUser
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 5),
              !message.isFromUser
                  ? GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: message.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text("پیام کپی شد"),
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 20),
                          SizedBox(width: 5),
                          Text("کپی پیام"),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
