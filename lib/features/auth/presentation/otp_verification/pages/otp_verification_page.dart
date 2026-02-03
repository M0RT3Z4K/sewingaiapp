// ============================================
// lib/features/otp_verification/presentation/pages/otp_verification_page.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:sewingaiapp/features/auth/presentation/otp_verification/bloc/otp_bloc.dart';
import 'package:sewingaiapp/features/auth/presentation/otp_verification/bloc/otp_event.dart';
import 'package:sewingaiapp/features/auth/presentation/otp_verification/bloc/otp_state.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phone;

  const OtpVerificationPage({super.key, required this.phone});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isError = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValidOtp = _otpController.text.length == 5;

    // استایل‌های Pinput
    final defaultPinTheme = PinTheme(
      width: 49.w,
      height: 52.h,
      textStyle: TextStyle(
        fontSize: 20.sp,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: _isError ? Color(0xffEA3323) : Color(0xffb8b8b8),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: _isError ? Color(0xffEA3323) : Color(0xff666666),
        width: 1,
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: _isError ? Color(0xffEA3323) : Color(0xff666666),
          width: 1,
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop;
      },
      child: Scaffold(
        body: BlocConsumer<OtpBloc, OtpState>(
          listener: (context, state) {
            if (state is OtpLoading) {
              setState(() {
                _isLoading = true;
                _isError = false;
              });
            } else {
              setState(() {
                _isLoading = false;
              });
            }

            if (state is OtpError) {
              setState(() {
                _isError = true;
              });
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

            if (state is OtpVerified) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/chat', (_) => false);
              // Navigator.of(context).pushReplacementNamed('/chat');
            }

            if (state is OtpResent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text('کد مجدداً ارسال شد'),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.fromLTRB(22.w, 60, 22.w, 24),
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
                                "V 1.1.0",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await _showExitDialog(context);
                              },
                              child: Icon(
                                LineAwesomeIcons.arrow_left_solid,
                                // Icons.arrow_forward_outlined,
                                color: Color(0xff757575),
                                size: 36.r,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          "کد را وارد کنید",
                          style: TextStyle(
                            fontSize: 40.sp,
                            letterSpacing: 0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          "کدی که برای شماره تلفن شما ارسال شده را در قسمت زیر وارد کنید",
                          style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 16.sp,
                            color: Color(0xff757575),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 25.h),

                        // Pinput
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Pinput(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            length: 5,
                            controller: _otpController,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            submittedPinTheme: submittedPinTheme,
                            showCursor: true,
                            onChanged: (_) {
                              setState(() {
                                _isError = false;
                              });
                            },
                            onCompleted: (pin) async {
                              if (!_isLoading) {
                                context.read<OtpBloc>().add(
                                  VerifyOtpEvent(widget.phone, pin),
                                );
                              }
                            },
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // Error Message
                        if (_isError) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Color(0xffEA3323),
                                size: 20.r,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                "کد وارد شده نامعتبر است.",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0,
                                  color: Color(0xffEA3323),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                        ],

                        SizedBox(height: 10.h),

                        // Verify Button
                        _buildLoadingButton(
                          onPressed: isValidOtp && !_isLoading
                              ? () {
                                  context.read<OtpBloc>().add(
                                    VerifyOtpEvent(
                                      widget.phone,
                                      _otpController.text.trim(),
                                    ),
                                  );
                                }
                              : null,
                          isLoading: _isLoading,
                          isEnabled: isValidOtp,
                          text: "تایید",
                        ),

                        SizedBox(height: 10.h),

                        // Change Number / Resend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "شماره را اشتباه وارد کردید؟",
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                SizedBox(width: 5.w),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "تغییر شماره",
                                    style: TextStyle(
                                      color: Color(0xff22A45D),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // GestureDetector(
                            //   onTap: () {
                            //     context.read<OtpBloc>().add(
                            //       ResendOtpEvent(widget.phone),
                            //     );
                            //   },
                            //   child: Text(
                            //     "ارسال مجدد",
                            //     style: TextStyle(
                            //       color: Color(0xff3EB9B4),
                            //       fontWeight: FontWeight.w500,
                            //       fontSize: 14.sp,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // اضافه کن به otp_verification_page.dart

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                contentPadding: EdgeInsets.all(16.r),
                titlePadding: EdgeInsets.all(16.r),
                actionsPadding: EdgeInsets.fromLTRB(16.r, 0, 0, 14.r),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                title: Text(
                  'بازگشت به صفحه قبل',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Text(
                  'آیا مطمئن هستید که می‌خواهید به صفحه وارد کردن شماره برگردید؟',
                  style: TextStyle(fontSize: 14.sp, color: Color(0xff757575)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'خیر',
                      style: TextStyle(
                        color: Color(0xff757575),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff3EB9B4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'بله',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            );
          },
        ) ??
        false; // اگه null بود، false برگردون
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
