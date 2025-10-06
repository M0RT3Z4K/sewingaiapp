import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:sewingaiapp/features/auth/presentation/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isPhoneButtonLoading = false;
  bool _isOtpButtonLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              _isPhoneButtonLoading = false;
              _isOtpButtonLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is Authenticated) {
            setState(() {
              _isOtpButtonLoading = false;
            });
            Navigator.of(context).pushReplacementNamed('/chat');
          }
          if (state is OtpSent) {
            // setState(() {
            //   _isPhoneButtonLoading = false;
            //   _phoneController.clear(); // اینجا کلیر کن
            // });
          }
          if (state is OTPVerifyError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_isOtpButtonLoading) {
                setState(() {
                  _isOtpButtonLoading = false;
                });
              }
            });
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return _buildOtpForm(context, "", isAuthanticated: true);
          }

          if (state is AuthInitial) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is Authenticated) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is OtpSent) {
            _isPhoneButtonLoading = false;
            // _phoneController.clear(); // اینجا کلیر کن

            return _buildOtpForm(context, state.phone);
          }
          if (state is OTPVerifyError) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await Future.delayed(Duration(milliseconds: 500));
              if (_isOtpButtonLoading) {
                setState(() {
                  _isOtpButtonLoading = false;
                });
              }
            });
            return _buildOtpForm(context, state.phone, isError: true);
          }

          return _buildPhoneForm(context);
        },
      ),
    );
  }

  bool isValidPhone = false;
  Widget _buildPhoneForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 68, 22.w, 24),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
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
                SizedBox(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextField(
                      maxLength: 11,
                      controller: _phoneController,
                      onChanged: (_) {
                        setState(() {
                          isValidPhone =
                              _phoneController.text.length >= 11 &&
                              _phoneController.text.substring(0, 2) == "09";
                        });
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
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xff8c8c8c),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // دکمه سفارشی با لودینگ
                _buildLoadingButton(
                  onPressed: isValidPhone && !_isPhoneButtonLoading
                      ? () {
                          final phone = _phoneController.text.trim();

                          setState(() {
                            _isPhoneButtonLoading = true;
                          });

                          context.read<AuthBloc>().add(SendOtp(phone));
                        }
                      : null,
                  isLoading: _isPhoneButtonLoading,
                  isEnabled: isValidPhone,
                  text: "دریافت کد",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpForm(
    BuildContext context,
    String phone, {
    bool isError = false,
    bool isAuthanticated = false,
  }) {
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
          color: isError ? Color(0xffEA3323) : Color(0xffb8b8b8),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: isError ? Color(0xffEA3323) : Color(0xff666666),

        width: 1,
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        // color: Color(0xfff5f5f5),
        border: Border.all(
          color: isError ? Color(0xffEA3323) : Color(0xff666666),
          width: 1,
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 60, 22.w, 24),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
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
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // Pinput برای OTP
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
                      setState(() {});
                    },
                    onCompleted: (pin) async {
                      // وقتی 5 رقم کامل شد، خودکار ارسال
                      if (!_isOtpButtonLoading) {
                        setState(() {
                          _isOtpButtonLoading = true;
                        });

                        context.read<AuthBloc>().add(VerifyOtp(phone, pin));
                        // await Future.delayed(Duration(milliseconds: 500));
                        // setState(() {
                        //   _isOtpButtonLoading = false;
                        // });
                      }
                    },
                  ),
                ),

                SizedBox(height: 10.h),
                if (isError) ...[
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

                // دکمه سفارشی با لودینگ
                _buildLoadingButton(
                  onPressed: isValidOtp && !_isOtpButtonLoading
                      ? () async {
                          setState(() {
                            _isOtpButtonLoading = true;
                          });

                          context.read<AuthBloc>().add(
                            VerifyOtp(phone, _otpController.text.trim()),
                          );
                          // setState(() {
                          //   _isOtpButtonLoading = false;
                          // });
                        }
                      : null,
                  isLoading: _isOtpButtonLoading,
                  isEnabled: isValidOtp,
                  text: "تایید",
                ),

                SizedBox(height: 10.h),
                Row(
                  children: [
                    Text(
                      "شماره را اشتباه وارد کردید؟",
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(width: 5.w),
                    GestureDetector(
                      onTap: () {
                        _otpController.clear();
                        setState(() {
                          _isOtpButtonLoading = false;
                        });
                        context.read<AuthBloc>().add(PageInitial());
                      },
                      child: Text(
                        "تغییر شماره",
                        style: TextStyle(
                          color: Color(0xff22A45D),
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade();
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
