import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sewingaiapp/features/version_check/presentation/bloc/version_state.dart';
import '../bloc/version_bloc.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VersionBloc, VersionState>(
      listener: (context, state) {
        if (state is VersionLoadSuccess) {
          final appVersion = state.appVersion;
          if (appVersion.latestVersion != state.Version) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
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
                          },
                          child: const Text("بعدا"),
                        ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,

                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text(
                      "نصب نسخه جدید",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          } else {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } else {}
      },
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
}
