import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewingaiapp/core/routes/app_route.dart';
import 'package:sewingaiapp/core/utils/constants.dart' as ENV;
import 'package:sewingaiapp/features/auth/domain/usecases/get_cached_token.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/get_user_with_token.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/login_or_signup.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/save_token.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/send_otp.dart'
    as sendOtpUsecase;
import 'package:sewingaiapp/features/auth/domain/usecases/verify_otp.dart'
    as verifyOtpUsecase;
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:sewingaiapp/features/auth/presentation/otp_verification/bloc/otp_bloc.dart';
import 'package:sewingaiapp/features/auth/presentation/phone_input/bloc/phone_bloc.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/get_current_user.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/send_message.dart';
import 'package:sewingaiapp/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:sewingaiapp/features/version_check/domain/usecases/check_app_version.dart';
import 'package:sewingaiapp/features/version_check/presentation/bloc/version_bloc.dart';
import 'package:sewingaiapp/features/version_check/presentation/bloc/version_event.dart';
import 'package:sewingaiapp/injection_container.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://khixujtzrrkcwdrqgebq.supabase.co',
    anonKey: ENV.SUPABASE_APIKEY,
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white, // navigation bar color
      statusBarColor: Colors.white, // status bar color
    ),
  );

  // final checkAppVersion = CheckAppVersion(versionRepository);

  await init();
  runApp(
    MyApp(
      checkAppVersion: getIt(),
      sendMessage: getIt(),
      sendImgMessage: getIt(),
      getCachedToken: getIt(),
      loginOrSignup: getIt(),
      saveToken: getIt(),
      sendOtp: getIt(),
      verifyOtp: getIt(),
      getUserWithToken: getIt(),
      getCurrentUser: getIt(),
    ),
  );
}

class MyApp extends StatefulWidget {
  final CheckAppVersion checkAppVersion;
  final SendMessage sendMessage;
  final SendImgMessage sendImgMessage;
  final GetCachedToken getCachedToken;
  final LoginOrSignup loginOrSignup;
  final SaveToken saveToken;
  final sendOtpUsecase.SendOtp sendOtp;
  final verifyOtpUsecase.VerifyOtp verifyOtp;
  final GetUserWithToken getUserWithToken;
  final GetCurrentUser getCurrentUser;

  const MyApp({
    Key? key,
    required this.checkAppVersion,
    required this.sendMessage,
    required this.sendImgMessage,
    required this.getCachedToken,
    required this.loginOrSignup,
    required this.saveToken,
    required this.sendOtp,
    required this.verifyOtp,
    required this.getUserWithToken,
    required this.getCurrentUser,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    initDeeplink();
  }

  Future<void> initDeeplink() async {
    final appLinks = AppLinks();

    appLinks.uriLinkStream.listen((uri) async {
      final user = await getIt<GetCurrentUser>().call();
      final got_user = await getIt<supabase.SupabaseClient>()
          .from("users")
          .select()
          .eq('token', user.token)
          .single();
      print(got_user);
      print(uri.queryParameters);
      if (got_user['payment_authority'] == uri.queryParameters["Authority"]) {
        if (uri.queryParameters["Status"] == "OK") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "پرداخت با موفقیت انجام شد و اشتراک شما فعال شده است.",
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("پرداخت شما ناموفق بود."),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("در پرداخت شما مشکلی به وجود آمده است."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      navigatorKey.currentState?.pushReplacementNamed(AppRoutes.profile);

      print(uri.queryParameters);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              VersionBloc(widget.checkAppVersion)..add(CheckVersionEvent()),
        ),
        BlocProvider(
          create: (_) => AuthBloc(
            getCachedToken: widget.getCachedToken,
            loginOrSignup: widget.loginOrSignup,
            saveToken: widget.saveToken,
            sendOtp: widget.sendOtp,
            verifyOtp: widget.verifyOtp,
            getUserWithToken: widget.getUserWithToken,
          )..add(PageInitial()),
        ),
        BlocProvider(create: (_) => getIt<PhoneBloc>()),
        BlocProvider(create: (_) => getIt<OtpBloc>()),
        BlocProvider(
          create: (_) => ChatBloc(
            sendMessageUseCase: widget.sendMessage,
            sendImgMessageUseCase: widget.sendImgMessage,
            getCurrentUserUseCase: widget.getCurrentUser,
          ),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Clean Chat AI',
          themeMode: ThemeMode.system,
          theme: ThemeData(primarySwatch: Colors.blue, fontFamily: "IRANSans"),
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}
