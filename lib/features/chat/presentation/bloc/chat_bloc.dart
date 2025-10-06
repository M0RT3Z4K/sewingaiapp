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

      // اگه لیست خالیه، پیام خوشامد اضافه کن
      if (_messages.isEmpty) {
        final welcomeMessage = Message(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          text: 'سلام. مایلید با دوره های آموزشی مریم بانو آشنا بشید؟',
          createdAt: DateTime.now(),
          isFromUser: false,
          isLoading: false,
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
      );
      _messages.add(userMessage);

      // تعیین پاسخ بات بر اساس انتخاب کاربر
      String botResponse;
      if (event.reply == 'بله') {
        botResponse =
            'عالی! لطفا از طریق لینک زیر وارد کانال ایتا شوید و توضیحات کامل را مطالعه کنید:\n\nhttps://eitaa.com/joinchat/581108722C65154713e7';
      } else {
        botResponse = 'سلام میتونی بهم کمک کنی؟';
      }

      final botMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: botResponse,
        createdAt: DateTime.now(),
        isFromUser: false,
        isLoading: false,
      );
      _messages.add(botMessage);

      emit(ChatLoaded(List.from(_messages), user));
    });

    on<ClearWelcomeMessages>((event, emit) async {
      User user = await getCurrentUserUseCase();

      // پاک کردن همه پیام‌هایی که isFromUser نیستن (پیام‌های خوشامد)
      // و نگه داشتن فقط پیام‌هایی که کاربر خودش فرستاده
      _messages.clear();

      emit(ChatLoaded(List.from(_messages), user));
    });
    on<SendUserMessage>((event, emit) async {
      User user = await getCurrentUserUseCase();

      if (_messages.length <= 3) {
        _messages.clear();
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

      if (_messages.length <= 3) {
        _messages.clear();
      }

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
