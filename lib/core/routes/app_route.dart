import 'package:flutter/material.dart';
import 'package:sewingaiapp/features/auth/presentation/otp_verification/pages/otp_verification_page.dart';
import 'package:sewingaiapp/features/auth/presentation/pages/login_page.dart';
import 'package:sewingaiapp/features/auth/presentation/phone_input/pages/phone_input_page.dart';
import 'package:sewingaiapp/features/chat/presentation/pages/chat_page.dart';
import 'package:sewingaiapp/features/home/presentation/pages/home_page.dart';
import 'package:sewingaiapp/features/version_check/presentation/pages/splash_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String phone = '/phone';
  static const String otp = '/otp';
  static const String chat = '/chat';
  static const String home = '/home';
  static const String login = '/login';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatPage());
      case phone:
        return MaterialPageRoute(builder: (_) => const PhoneInputPage());
      case otp:
        final phone = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationPage(phone: phone),
        );
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}
