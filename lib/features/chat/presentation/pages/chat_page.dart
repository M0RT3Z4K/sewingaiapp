import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sewingaiapp/core/routes/app_route.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/logout.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:sewingaiapp/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:sewingaiapp/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:sewingaiapp/features/chat/domain/entities/message.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/get_current_user.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/send_message.dart';
import 'package:sewingaiapp/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:sewingaiapp/features/chat/presentation/bloc/chat_event.dart';
import 'package:sewingaiapp/features/chat/presentation/bloc/chat_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _showShadow = false;

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
    _scrollController.addListener(() {
      print(_scrollController.position.maxScrollExtent);
      print(MediaQuery.of(context).size.height);

      if (_scrollController.offset > 0 && !_showShadow) {
        setState(() => _showShadow = true);
      } else if (_scrollController.offset <= 0 && _showShadow) {
        if (_scrollController.position.maxScrollExtent >
            MediaQuery.of(context).size.height) {
          setState(() => _showShadow = true);
        } else {
          setState(() => _showShadow = false);
        }
      }
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent - 2) {
        setState(() => _showShadow = false);
      }
    });
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
      drawerEnableOpenDragGesture: false,
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Directionality(
        textDirection: TextDirection.rtl,
        child: Drawer(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.zero),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.r,
                    vertical: 15.h,
                  ),
                  child: Text(
                    "منو",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  horizontalTitleGap: 5.w,
                  leading: Icon(Icons.logout),
                  title: Text("خروج"),
                  onTap: () {
                    GetIt.instance<Logout>().call();
                    context.read<AuthBloc>().add(PageInitial());
                    Navigator.of(context).pushReplacementNamed(AppRoutes.phone);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        scrolledUnderElevation: 0,
        elevation: 0,
        bottom: _showShadow
            ? PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Container(color: Color(0xffbfbfbf), height: 1),
              )
            : null,
        leadingWidth: 45.w,
        leading: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: Icon(
            Icons.account_circle_outlined,
            size: 28.r,
            color: Colors.black,
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.black, size: 28.r),
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
            return Center(
              child: const CircularProgressIndicator(color: Color(0xff3EB9B4)),
            );
          }
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xff3EB9B4)),
            );
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
                      horizontal: 6.w,
                      // vertical: 8.h,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      final isUser = m.isFromUser;

                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.sizeOf(context).width * 0.8,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.r,
                                    vertical: 12.r,
                                  ),
                                  margin: EdgeInsets.only(bottom: 7.r),

                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? Color(0xff3EB9B4)
                                        : Color(0xffE8E8E8),
                                    borderRadius: BorderRadius.circular(17.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!m.isLoading) ...[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (m.imageFile != null)
                                              Image.file(
                                                m.imageFile!,
                                                height: 200,
                                              ),
                                            if (m.imageUrl != null)
                                              Image.network(
                                                m.imageUrl!,
                                                width: 200,
                                              ),
                                            // SizedBox(height: 10),

                                            // Text(
                                            //   m.text,
                                            //   style: TextStyle(
                                            //     color: m.isFromUser
                                            //         ? Colors.white
                                            //         : Colors.black87,
                                            //     fontSize: 16,
                                            //   ),
                                            // ),
                                            buildMessageText(
                                              m.text,
                                              m.isFromUser,
                                            ),
                                          ],
                                        ),
                                        if (!isUser &&
                                            m.isWelcomeMessage &&
                                            m.hasButtons &&
                                            messages.indexOf(m) >
                                                messages.length - 2) ...[
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
                                            m.isWelcomeMessage &&
                                            m.hasButtons &&
                                            messages.indexOf(m) >
                                                messages.length - 4 &&
                                            messages.indexOf(m) <=
                                                messages.length - 3)
                                          _buildLinkButtons(),

                                        if (!isUser &&
                                            !m.isLoading &&
                                            !m.isWelcomeMessage) ...[
                                          SizedBox(height: 4.h),
                                          _buildActionIcon(m),
                                        ],
                                      ],
                                      if (m.isLoading) ...[
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

                                // دکمه‌های پیشنهادی (اگر وجود داشته باشد)

                                // لودینگ
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Input Area
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(left: 6.w, right: 6.w, bottom: 8.h),
                  child: SafeArea(
                    child: Column(
                      children: [
                        if (picked != null) ...[
                          Container(
                            padding: EdgeInsets.all(2.r),
                            margin: EdgeInsets.only(bottom: 5.h),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(17.r),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(17.r),
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
                        SizedBox(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // آیکون attach
                                        SizedBox(width: 8.w),

                                        // TextField
                                        Expanded(
                                          child: TextField(
                                            controller: _controller,
                                            minLines: 1,
                                            maxLines: 4,
                                            onSubmitted: (_) => _send(),
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              letterSpacing: 0,
                                            ),
                                            decoration: InputDecoration(
                                              hintText:
                                                  'پیام خود را بنویسید...',
                                              hintStyle: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 15.sp,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 4.w,
                                                    vertical: 2.h,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        // SizedBox(width: 12.w),
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
                                                              source:
                                                                  ImageSource
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
                                                  picked = await picker
                                                      .pickImage(
                                                        source:
                                                            ImageSource.gallery,
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
                              SizedBox(width: 6.w),
                              Container(
                                width: 40.w,
                                height: 40.h,
                                decoration: BoxDecoration(
                                  color: Color(0xff3EB9B4),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 18.r,
                                  ),
                                  onPressed: messages.isEmpty
                                      ? () {
                                          if (picked == null) {
                                            _send();
                                            _scrollController.animateTo(
                                              0,
                                              duration: Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                          } else {
                                            _sendImg(File(picked.path));
                                            _scrollController.animateTo(
                                              0,
                                              duration: Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                            picked = null;
                                            setState(() {});
                                          }
                                        }
                                      : messages.first.isLoading
                                      ? null
                                      : () {
                                          if (picked == null) {
                                            _send();
                                            _scrollController.animateTo(
                                              0,
                                              duration: Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                          } else {
                                            _sendImg(File(picked.path));
                                            _scrollController.animateTo(
                                              0,
                                              duration: Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                            picked = null;
                                            setState(() {});
                                          }
                                        },
                                ),
                              ),

                              // Text Input
                            ],
                          ),
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
    return Expanded(
      child: GestureDetector(
        onTap: () {
          bloc.add(SendQuickReply(text));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Color(0xff3EA3B9),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                bloc.add(ClearWelcomeMessages());
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: Color(0xff3EA3B9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    "بستن",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),

          Expanded(
            child: GestureDetector(
              onTap: () => launchUrl(
                Uri.parse("https://eitaa.com/joinchat/581108722C65154713e7"),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: Color(0xff3EA3B9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    "توضیحات بیشتر",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(Message m) {
    return Row(
      mainAxisSize: MainAxisSize.min,

      children: [
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: m.text));
            Fluttertoast.showToast(
              msg: "متن پیام کپی شد",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.sp,
            );
          },
          child: Icon(
            Icons.copy,
            size: 19.r,
            weight: 1.5,
            color: Color(0xff737373),
          ),
        ),
        SizedBox(width: 7.w),
        GestureDetector(
          onTap: () {
            SharePlus.instance.share(
              ShareParams(
                text: "${m.text}\n\nارسال شده توسط اپلیکیشن مربی هوشمند خیاطی",
              ),
            );
          },
          child: Icon(
            Icons.share_outlined,
            size: 20.r,
            weight: 1.5,
            color: Color(0xff737373),
          ),
        ),
        SizedBox(width: 5.w),
        GestureDetector(
          onTap: () {},
          child: Icon(
            Icons.bookmark_border,
            size: 20.r,
            weight: 1.5,
            color: Color(0xff737373),
          ),
        ),
      ],
    );
  }

  Widget buildMessageText(String text, bool isUser) {
    return MarkdownBody(
      data: text,
      // selectable: true, // اگه میخوای قابل انتخاب باشه
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: isUser ? Colors.white : Colors.black,
          fontSize: 14,
          height: 1.4,
        ),
        code: TextStyle(
          backgroundColor: isUser ? Colors.white24 : Colors.grey[300],
          color: isUser ? Colors.white : Colors.black87,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: isUser ? Colors.white24 : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        blockquote: TextStyle(
          color: isUser ? Colors.white70 : Colors.black54,
          fontStyle: FontStyle.italic,
        ),
        h1: TextStyle(
          color: isUser ? Colors.white : Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: isUser ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: isUser ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        listBullet: TextStyle(color: isUser ? Colors.white : Colors.black),
        tableBody: TextStyle(color: isUser ? Colors.white : Colors.black),
        tableBorder: TableBorder.all(
          color: isUser ? Colors.white24 : Colors.grey[300]!,
        ),
      ),
    );
  }
}
