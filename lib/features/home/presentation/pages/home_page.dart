import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/bg.jpg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PillButton(
                      label: 'مربی هوشمند خیاطی',
                      onTap: () {
                        Navigator.of(context).pushNamed('/chat');
                      },
                      // اگر لوگو داری از asset استفاده کن:
                      // logo: Image.asset('assets/logo.png', height: 24),
                      logo: Image.asset(
                        'assets/logo2.png',
                        height: 45,
                      ), // نمونه
                      background: Color(0xffFF69B4),
                      foreground: Colors.black,
                    ),
                    const SizedBox(height: 50),
                    PillButton(
                      label: 'دوره نازک دوز خیاطی زیتون',
                      onTap: () {
                        _launchUrl(
                          Uri.parse("https://eitaa.com/khayati_maryambanoo"),
                        );
                      },
                      logo: Image.asset(
                        'assets/logo1.png',
                        height: 45,
                      ), // نمونه
                      background: Color(0xff3EAC19),
                      foreground: Colors.black,
                    ),
                    const SizedBox(height: 50),
                    PillButton(
                      label: 'آموزش رایگان خیاطی مریم بانو',
                      onTap: () {
                        _launchUrl(
                          Uri.parse("https://eitaa.com/khayati_maryambanoo"),
                        );
                      },
                      logo: Image.asset(
                        'assets/logo3.png',
                        height: 45,
                      ), // نمونه
                      background: Color(0xff48D1CC),
                      foreground: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// یک دکمهٔ Pill سفارشی با متن وسط و لوگو در سمت راست
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Widget? logo;
  final Color? background;
  final Color? foreground;
  final double height;
  final double radius;

  const PillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.logo,
    this.background,
    this.foreground,
    this.height = 56,
    this.radius = 999, // کاملاً گرد
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ?? Theme.of(context).colorScheme.primary;
    final fg = foreground ?? Theme.of(context).colorScheme.onPrimary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          // برای اینکه متن دقیقاً وسط بایستد و لوگو سمت راست بماند، از Stack استفاده می‌کنیم
          child: Stack(
            alignment: Alignment.center,
            children: [
              // متن مرکز
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // لوگو/آیکون سمت راست
              if (logo != null)
                Positioned(
                  right: 5,
                  child: IconTheme(
                    data: IconThemeData(color: fg, size: 24),
                    child: logo!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
