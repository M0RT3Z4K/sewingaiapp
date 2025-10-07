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
  bool _hasWelcomeBeenCleared = false; // اضافه کن این flag رو

  ChatBloc({
    required this.sendMessageUseCase,
    required this.sendImgMessageUseCase,
    required this.getCurrentUserUseCase,
  }) : super(ChatInitial()) {
    on<LoadHistory>((event, emit) async {
      final user = await getCurrentUserUseCase();

      // اگه لیست خالیه، پیام خوشامد اضافه کن
      if (_messages.isEmpty) {
        final welcomeMessage = Message(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          text: 'سلام. مایلید با دوره های آموزشی مریم بانو آشنا بشید؟',
          createdAt: DateTime.now(),
          isFromUser: false,
          isLoading: false,
          isWelcomeMessage: true, // مهم!
          hasButtons: true, // مهم!
        );
        _messages.add(welcomeMessage);
      }

      emit(ChatLoaded(List.from(_messages), user));
    });

    on<SendQuickReply>((event, emit) async {
      User user = await getCurrentUserUseCase();

      // اضافه کردن پیام کاربر
      final userMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.reply,
        createdAt: DateTime.now(),
        isFromUser: true,
        isLoading: false,
        isWelcomeMessage: true, // مهم!
        hasButtons:
            false, // مهم! (حالا که کاربر جواب داده، دیگه دکمه‌ها نباید باشن
      );
      _messages.add(userMessage);

      // تعیین پاسخ بات بر اساس انتخاب کاربر
      String botResponse;
      Message botMessage;
      if (event.reply == 'بله') {
        botResponse =
            'عالی! لطفا از طریق لینک زیر وارد کانال ایتا شوید و توضیحات کامل را مطالعه کنید:\n\nhttps://eitaa.com/joinchat/581108722C65154713e7';
        botMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: botResponse,
          createdAt: DateTime.now(),
          isFromUser: false,
          isLoading: false,
          isWelcomeMessage: true,
          hasButtons: true, // مهم! (بعد از پاسخ بات، دکمه‌ها نباید باشن
        );
      } else {
        if (!_hasWelcomeBeenCleared) {
          _messages.removeWhere((msg) => msg.isWelcomeMessage == true);
          _hasWelcomeBeenCleared = true; // علامت بزن که پاک شده
        }
        botResponse = 'سلام. چطور میتونم بهتون کمک کنم؟';
        botMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: botResponse,
          createdAt: DateTime.now(),
          isFromUser: false,
          isLoading: false,
          isWelcomeMessage: false,
          hasButtons: false, // مهم! (بعد از پاسخ بات، دکمه‌ها نباید باشن
        );
      }

      _messages.add(botMessage);

      emit(ChatLoaded(List.from(_messages), user));
    });

    on<ClearWelcomeMessages>((event, emit) async {
      User user = await getCurrentUserUseCase();

      if (!_hasWelcomeBeenCleared) {
        _messages.removeWhere((msg) => msg.isWelcomeMessage == true);
        _hasWelcomeBeenCleared = true; // علامت بزن که پاک شده
      }

      final botMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'سلام. چطور میتونم بهتون کمک کنم؟',
        createdAt: DateTime.now(),
        isFromUser: false,
        isLoading: false,
        isWelcomeMessage: false,
        hasButtons: false, // مهم! (بعد از پاسخ بات، دکمه‌ها نباید باشن
      );
      _messages.add(botMessage);

      emit(ChatLoaded(List.from(_messages), user));
    });
    on<SendUserMessage>((event, emit) async {
      User user = await getCurrentUserUseCase();

      if (!_hasWelcomeBeenCleared) {
        _messages.removeWhere((msg) => msg.isWelcomeMessage == true);
        _hasWelcomeBeenCleared = true; // علامت بزن که پاک شده
      }

      print(event.text);
      try {
        // اضافه کردن پیام کاربر به لیست
        final userMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: event.text,
          createdAt: DateTime.now(),
          isFromUser: true,
          isLoading: false,
          isWelcomeMessage: false, // این پیام واقعیه
        );
        _messages.add(userMessage);
        Message aiMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '',
          createdAt: DateTime.now(),
          isFromUser: false,
          isLoading: true,
          isWelcomeMessage: false, // این پیام واقعیه
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

      if (!_hasWelcomeBeenCleared) {
        _messages.removeWhere((msg) => msg.isWelcomeMessage == true);
        _hasWelcomeBeenCleared = true; // علامت بزن که پاک شده
      }

      final userImgMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.text,
        createdAt: DateTime.now(),
        isFromUser: true,
        isLoading: false,
        imageFile: event.image,
        isWelcomeMessage: false, // این پیام واقعیه
      );
      _messages.add(userImgMessage);
      Message aiImgMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '',
        createdAt: DateTime.now(),
        isFromUser: false,
        isLoading: true,
        isWelcomeMessage: false, // این پیام واقعیه
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
