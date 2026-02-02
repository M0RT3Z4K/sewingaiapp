import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:sewingaiapp/features/version_check/presentation/bloc/version_state.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/version_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _versionCheckCompleted = false;
  bool _authCheckStarted = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ============================================
        // LISTENER 1: چک کردن ورژن (اولویت اول)
        // ============================================
        BlocListener<VersionBloc, VersionState>(
          listener: (context, versionState) {
            if (versionState is VersionLoadSuccess) {
              final appVersion = versionState.appVersion;

              print('✅ Version check completed');
              print('📱 Current version: ${versionState.Version}');
              print('🆕 Latest version: ${appVersion.latestVersion}');

              // بررسی نیاز به آپدیت
              if (appVersion.latestVersion != versionState.Version) {
                // نمایش دیالوگ آپدیت
                showDialog(
                  context: context,
                  barrierDismissible: !appVersion.isForced,
                  builder: (ctx) => WillPopScope(
                    onWillPop: () async => !appVersion.isForced,
                    child: AlertDialog(
                      title: const Text("به روزرسانی برنامه"),
                      content: Directionality(
                        textDirection: TextDirection.rtl,
                        child: const Text(
                          "نسخه جدیدی از برنامه در دسترس است. برای استفاده از جدیدترین امکانات لطفا نسخه جدید را نصب کنید.",
                        ),
                      ),
                      actions: <Widget>[
                        if (!appVersion.isForced)
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 5,
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              print('⏭️ User skipped update');
                              _startAuthCheck(context);
                            },
                            child: const Text("بعدا"),
                          ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            elevation: 5,
                          ),
                          onPressed: () {
                            print('📥 User clicked download update');
                            launchUrl(Uri.parse(appVersion.downloadLink));
                            // Navigator.of(ctx).pop();
                          },
                          child: const Text(
                            "نصب نسخه جدید",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // ورژن به‌روز است
                print('✅ App is up to date');
                _startAuthCheck(context);
              }
            } else if (versionState is VersionFailure) {
              print('❌ Version check failed: ${versionState.message}');
              _startAuthCheck(context);
            }
          },
        ),

        // ============================================
        // LISTENER 2: چک کردن احراز هویت (اولویت دوم)
        // ============================================
        BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            // فقط بعد از شروع auth check navigation انجام بده
            if (!_authCheckStarted) return;

            print('🔐 Auth state changed: ${authState.runtimeType}');

            if (authState is Authenticated) {
              print('✅ User authenticated, navigating to chat');
              Navigator.of(context).pushReplacementNamed('/chat');
            } else if (authState is Authanticating) {
              print('❌ User not authenticated, navigating to login');
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Color(0xff48d1cc),
        body: Stack(
          children: [
            Center(child: Image.asset('assets/logo3.png', height: 200)),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SpinKitThreeBounce(
                  size: 25,
                  itemBuilder: (BuildContext context, int index) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: index.isEven ? Colors.white : Colors.white70,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                    );
                  },
                ),
                SizedBox(height: 120),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // شروع auth check بعد از تکمیل version check
  void _startAuthCheck(BuildContext context) {
    if (_versionCheckCompleted) {
      print('⚠️ Auth check already started');
      return;
    }

    setState(() {
      _versionCheckCompleted = true;
      _authCheckStarted = true;
    });

    print('🚀 Starting auth check...');

    // حالا event رو بزن تا AuthBloc شروع به کار کنه
    context.read<AuthBloc>().add(PageInitial());
  }
}
