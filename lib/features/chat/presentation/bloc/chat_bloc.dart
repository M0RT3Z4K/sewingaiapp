import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sewingaiapp/features/auth/domain/entities/user.dart';
import 'package:sewingaiapp/features/chat/domain/entities/message.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/get_current_user.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/send_message.dart';
import 'package:sewingaiapp/features/chat/presentation/bloc/chat_event.dart';
import 'package:sewingaiapp/features/chat/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage sendMessageUseCase;
  final SendImgMessage sendImgMessageUseCase;
  final GetCurrentUser getCurrentUserUseCase;

  // نگهداری تاریخچه محلی ساده
  final List<Message> _messages = [];
  final User? user = null;

  ChatBloc({
    required this.sendMessageUseCase,
    required this.sendImgMessageUseCase,
    required this.getCurrentUserUseCase,
  }) : super(ChatInitial()) {
    on<LoadHistory>((event, emit) async {
      final user = await getCurrentUserUseCase();

      emit(ChatLoading());
      emit(ChatLoaded(List.from(_messages), user));
    });

    on<SendUserMessage>((event, emit) async {
      User user = await getCurrentUserUseCase();

      print(event.text);
      try {
        // اضافه کردن پیام کاربر به لیست
        final userMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: event.text,
          createdAt: DateTime.now(),
          isFromUser: true,
          isLoading: false,
        );
        _messages.add(userMessage);
        Message aiMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '',
          createdAt: DateTime.now(),
          isFromUser: false,
          isLoading: true,
        );
        _messages.add(aiMessage);

        emit(ChatLoaded(List.from(_messages), user));

        // گرفتن پاسخ از هوش مصنوعی
        // emit(ChatLoading());

        final response = await sendMessageUseCase(event.text, _messages);
        user = await getCurrentUserUseCase();

        _messages.removeLast();
        _messages.add(response);
        emit(ChatLoaded(List.from(_messages), user));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });

    on<SendImageMessage>((event, emit) async {
      User user = await getCurrentUserUseCase();

      final userImgMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.text,
        createdAt: DateTime.now(),
        isFromUser: true,
        isLoading: false,
        imageFile: event.image,
      );
      _messages.add(userImgMessage);
      Message aiImgMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '',
        createdAt: DateTime.now(),
        isFromUser: false,
        isLoading: true,
      );
      _messages.add(aiImgMessage);

      emit(ChatLoaded(List.from(_messages), user));

      final response = await sendImgMessageUseCase(
        event.text,
        _messages,
        event.image,
      );
      user = await getCurrentUserUseCase();

      _messages.removeLast();
      _messages.add(response);

      emit(ChatLoaded(List.from(_messages), user));

      // اینجا می‌تونی آپلود کنی و آدرسشو بذاری:
      // final url = await chatRepository.uploadImage(event.image);
      // بعد استیتو آپدیت کنی که imageUrl پر بشه
    });
  }
}
