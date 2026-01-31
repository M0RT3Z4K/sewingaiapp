import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/get_current_user.dart';
import 'package:sewingaiapp/features/version_check/presentation/bloc/version_state.dart';
import 'package:sewingaiapp/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../bloc/version_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    final appLinks = AppLinks();

    final sub = appLinks.uriLinkStream.listen((uri) async {
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
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "پرداخت با موفقیت انجام شد و اشتراک شما فعال شده است.",
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        } else {
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("پرداخت شما ناموفق بود."),
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        }
      } else {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("در پرداخت شما مشکلی به وجود آمده است."),
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
      }

      setState(() {
        Navigator.of(context).pushReplacementNamed('/profile');
      });

      print(uri.queryParameters);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener برای چک کردن ورژن
        BlocListener<VersionBloc, VersionState>(
          listener: (context, versionState) {
            if (versionState is VersionLoadSuccess) {
              final appVersion = versionState.appVersion;

              // اگر ورژن جدید وجود داره
              if (appVersion.latestVersion != versionState.Version) {
                showDialog(
                  context: context,
                  barrierDismissible: !appVersion.isForced,
                  builder: (ctx) => WillPopScope(
                    onWillPop: () async => !appVersion.isForced,
                    child: AlertDialog(
                      title: const Text("به روزرسانی برنامه"),
                      content: const Text(
                        "نسخه جدیدی از برنامه در دسترس است. برای استفاده از جدیدترین امکانات لطفا نسخه جدید را نصب کنید.",
                      ),
                      actions: <Widget>[
                        appVersion.isForced
                            ? const SizedBox()
                            : TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 5,
                                ),
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  // بعد از بستن دیالوگ، ادامه به چک کردن auth
                                  _checkAuthAfterVersionCheck(context);
                                },
                                child: const Text("بعدا"),
                              ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            elevation: 5,
                          ),
                          onPressed: () {
                            // اینجا باید لینک دانلود رو باز کنی
                            // launchUrl(Uri.parse(appVersion.downloadLink));
                            Navigator.of(ctx).pop();
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
                // اگر ورژن به‌روز بود، چک کردن auth
                _checkAuthAfterVersionCheck(context);
              }
            }
          },
        ),

        // Listener برای چک کردن وضعیت احراز هویت
        BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is Authenticated) {
              // اگر یوزر قبلا لاگین کرده بود، بره به صفحه چت
              Navigator.of(context).pushReplacementNamed('/chat');
            } else if (authState is AuthInitial) {
              // اگر لاگین نکرده بود، بره به صفحه لاگین
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

  // این متد بعد از چک ورژن، وضعیت auth رو بررسی میکنه
  void _checkAuthAfterVersionCheck(BuildContext context) {
    // اینجا دیگه از AuthBloc که از قبل ساخته شده استفاده میکنیم
    // چون تو main.dart در MultiBlocProvider اضافه شده
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      Navigator.of(context).pushReplacementNamed('/chat');
    } else if (authState is AuthInitial) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
    // اگر AuthLoading یا حالت دیگه ای بود، صبر میکنه تا BlocListener بالا هندلش کنه
  }
}
