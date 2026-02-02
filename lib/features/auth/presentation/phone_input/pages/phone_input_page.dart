// ============================================
// lib/features/phone_input/presentation/pages/phone_input_page.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sewingaiapp/features/auth/presentation/phone_input/bloc/phone_bloc.dart';
import 'package:sewingaiapp/features/auth/presentation/phone_input/bloc/phone_event.dart';
import 'package:sewingaiapp/features/auth/presentation/phone_input/bloc/phone_state.dart';

class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({super.key});

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValidPhone =
        _phoneController.text.length >= 11 &&
        _phoneController.text.substring(0, 2) == "09";

    return Scaffold(
      body: BlocConsumer<PhoneBloc, PhoneState>(
        listener: (context, state) {
          if (state is PhoneLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }

          if (state is PhoneError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(state.message),
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (state is PhoneOtpSent) {
            // Navigate to OTP page
            Navigator.of(context).pushNamed('/otp', arguments: state.phone);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.fromLTRB(22.w, 68, 22.w, 24),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                children: [
                  // Footer
                  Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "مربی هوشمند خیاطی - ",
                              style: TextStyle(
                                color: Color(0xffc5c5c5),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "V 1.0.0",
                              style: TextStyle(
                                color: Color(0xffc5c5c5),
                                fontFamily: "vazir",
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "خوش آمدید!",
                        style: TextStyle(
                          fontSize: 40.sp,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "برای استفاده از برنامه می‌بایست شماره تلفن خود را وارد نمائید.",
                        style: TextStyle(
                          letterSpacing: 0,
                          fontSize: 16.sp,
                          color: Color(0xff757575),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        "شماره تلفن:",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: TextField(
                          maxLength: 11,
                          controller: _phoneController,
                          enabled: !_isLoading,
                          onChanged: (_) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: "09123456789",
                            counterText: "",
                            hintStyle: TextStyle(color: Color(0xffc2c2c2)),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 15.r,
                              horizontal: 14.r,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffb8b8b8),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xff8c8c8c),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffb8b8b8),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Send Button
                      _buildLoadingButton(
                        onPressed: isValidPhone && !_isLoading
                            ? () {
                                final phone = _phoneController.text.trim();
                                context.read<PhoneBloc>().add(
                                  SendOtpEvent(phone),
                                );
                              }
                            : null,
                        isLoading: _isLoading,
                        isEnabled: isValidPhone,
                        text: "دریافت کد",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required bool isEnabled,
    required String text,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: double.infinity,
        height: 43.5.h,
        decoration: BoxDecoration(
          color: isEnabled ? Color(0xff3EB9B4) : Color(0xffc2c2c2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    letterSpacing: 0,
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
