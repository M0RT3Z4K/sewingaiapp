import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sewingaiapp/features/auth/domain/entities/user.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/login_or_signup.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/save_token.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/send_otp.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/verify_otp.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final VerifyOtp verifyOtp;
  final LoginOrSignup loginOrSignup;
  final SaveToken saveToken;
  final SendOtp sendOtp;

  OtpBloc({
    required this.verifyOtp,
    required this.loginOrSignup,
    required this.saveToken,
    required this.sendOtp,
  }) : super(OtpInitial()) {
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
  }

  void _onVerifyOtp(VerifyOtpEvent event, Emitter<OtpState> emit) async {
    emit(OtpLoading());

    try {
      await Future.delayed(Duration(milliseconds: 500));

      bool verified = await verifyOtp(event.phone, event.otp);

      if (verified) {
        User user = await loginOrSignup(event.phone);
        await saveToken(user.token);
        emit(OtpVerified(user));
      } else {
        emit(OtpError('کد وارد شده نامعتبر است.'));
      }
    } catch (e) {
      emit(OtpError(e.toString()));
    }
  }

  void _onResendOtp(ResendOtpEvent event, Emitter<OtpState> emit) async {
    try {
      await sendOtp(event.phone);
      emit(OtpResent());
      emit(OtpInitial());
    } catch (e) {
      emit(OtpError('خطا در ارسال مجدد کد'));
    }
  }
}
