import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sewingaiapp/core/routes/app_route.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/logout.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:sewingaiapp/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:sewingaiapp/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/get_current_user.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/send_message.dart';
import 'package:sewingaiapp/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:sewingaiapp/features/chat/presentation/bloc/chat_event.dart';
import 'package:sewingaiapp/features/chat/presentation/bloc/chat_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin<ChatPage> {
  late final ChatBloc bloc;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  var picked;

  @override
  void initState() {
    super.initState();
    final remote = ChatRemoteDataSourceImpl(GetIt.instance(), GetIt.instance());
    final repo = ChatRepositoryImpl(remote);
    bloc = ChatBloc(
      sendMessageUseCase: SendMessage(repo),
      sendImgMessageUseCase: SendImgMessage(repo),
      getCurrentUserUseCase: GetCurrentUser(repo),
    );
    bloc.add(LoadHistory());
  }

  @override
  void dispose() {
    bloc.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    bloc.add(SendUserMessage(text));
    _controller.clear();
  }

  void _sendImg(image) {
    final text = _controller.text.trim();
    bloc.add(SendImageMessage(text, image));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: Directionality(
        textDirection: TextDirection.rtl,
        child: Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Text(
                    "منو",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("خروج"),
                  onTap: () {
                    GetIt.instance<Logout>().call();
                    context.read<AuthBloc>().add(PageInitial());
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 60.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey[700]),
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.black, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is ChatInitial) {
            return const Center(child: Text('شروع گفتگو'));
          }
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatLoaded) {
            final messages = state.messages.reversed.toList();
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      final isUser = m.isFromUser;

                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Row(
                            mainAxisAlignment: isUser
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // if (!isUser) ...[
                              //   CircleAvatar(
                              //     radius: 16.r,
                              //     backgroundColor: Colors.grey[300],
                              //     child: Icon(Icons.smart_toy, size: 18.r),
                              //   ),
                              //   SizedBox(width: 8.w),
                              // ],
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: isUser
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.sizeOf(context).width *
                                            0.8,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),

                                      decoration: BoxDecoration(
                                        color: isUser
                                            ? Color(0xff3EB9B4)
                                            : Color(0xffE8E8E8),
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.text,
                                            style: TextStyle(
                                              color: isUser
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 14.sp,
                                              height: 1.4,
                                            ),
                                          ),
                                          if (!isUser &&
                                              messages.length == 2) ...[
                                            SizedBox(height: 8.h),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _buildSuggestionButton('بله'),
                                                SizedBox(width: 8.w),
                                                _buildSuggestionButton('خیر'),
                                              ],
                                            ),
                                          ],

                                          if (!isUser &&
                                              !m.isLoading &&
                                              messages.length > 2) ...[
                                            SizedBox(height: 8.h),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _buildActionIcon(
                                                  Icons.copy,
                                                  () {},
                                                ),
                                                SizedBox(width: 12.w),
                                                _buildActionIcon(
                                                  Icons.share,
                                                  () {},
                                                ),
                                                SizedBox(width: 12.w),
                                                _buildActionIcon(
                                                  Icons.bookmark_border,
                                                  () {},
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // دکمه‌های پیشنهادی (اگر وجود داشته باشد)

                                    // لودینگ
                                    if (m.isLoading) ...[
                                      SizedBox(height: 8.h),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 20.w,
                                            height: 20.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Input Area
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        if (picked != null) ...[
                          Container(
                            padding: EdgeInsets.all(8.r),
                            margin: EdgeInsets.only(bottom: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.file(
                                    File(picked.path),
                                    height: 60.h,
                                    width: 60.w,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      picked = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        Row(
                          children: [
                            // دکمه ارسال
                            Expanded(
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xffF5F5F5),
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  child: Row(
                                    children: [
                                      // آیکون attach
                                      SizedBox(width: 12.w),

                                      // TextField
                                      Expanded(
                                        child: TextField(
                                          controller: _controller,
                                          minLines: 1,
                                          maxLines: 4,
                                          onSubmitted: (_) => _send(),
                                          style: TextStyle(fontSize: 15.sp),
                                          decoration: InputDecoration(
                                            hintText: 'پیام خود را بنویسید...',
                                            hintStyle: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 15.sp,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 4.w,
                                                  vertical: 12.h,
                                                ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      IconButton(
                                        icon: Icon(
                                          Icons.attach_file,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: messages.isEmpty
                                            ? state.user.imageInDay < 3
                                                  ? () async {
                                                      final picker =
                                                          ImagePicker();
                                                      picked = await picker
                                                          .pickImage(
                                                            source: ImageSource
                                                                .gallery,
                                                          );
                                                      setState(() {});
                                                    }
                                                  : null
                                            : messages.first.isLoading
                                            ? null
                                            : state.user.imageInDay < 3
                                            ? () async {
                                                final picker = ImagePicker();
                                                picked = await picker.pickImage(
                                                  source: ImageSource.gallery,
                                                );
                                                setState(() {});
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 48.w,
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: Color(0xff3EB9B4),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                onPressed: messages.isEmpty
                                    ? () {
                                        if (picked == null) {
                                          _send();
                                        } else {
                                          _sendImg(File(picked.path));
                                          picked = null;
                                          setState(() {});
                                        }
                                      }
                                    : messages.first.isLoading
                                    ? null
                                    : () {
                                        if (picked == null) {
                                          _send();
                                        } else {
                                          _sendImg(File(picked.path));
                                          picked = null;
                                          setState(() {});
                                        }
                                      },
                              ),
                            ),

                            // Text Input
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is ChatError) {
            return Center(child: Text('خطا: ${state.message}'));
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSuggestionButton(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _send();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Color(0xff3EB9B4),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 20.r, color: Colors.grey[600]),
    );
  }
}
