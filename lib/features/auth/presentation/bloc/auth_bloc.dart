import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sewingaiapp/features/auth/domain/entities/user.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/get_cached_token.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/get_user_with_token.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/login_or_signup.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/save_token.dart';

import 'package:sewingaiapp/features/auth/domain/usecases/send_otp.dart'
    as sendOtpUsecase;
import 'package:sewingaiapp/features/auth/domain/usecases/verify_otp.dart'
    as verifyOtpUsecase;
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCachedToken getCachedToken;
  final LoginOrSignup loginOrSignup;
  final SaveToken saveToken;
  final GetUserWithToken getUserWithToken;
  final sendOtpUsecase.SendOtp sendOtp;
  final verifyOtpUsecase.VerifyOtp verifyOtp;

  AuthBloc({
    required this.getCachedToken,
    required this.loginOrSignup,
    required this.saveToken,
    required this.sendOtp,
    required this.verifyOtp,
    required this.getUserWithToken,
  }) : super(AuthInitial()) {
    on<SendOtp>(_onSendOtp);
    on<VerifyOtp>(_onVerifyOtp);
    on<PageInitial>(_onInit);
  }

  void _onInit(PageInitial event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
    print("pageinitial");
    String? authToken = await getCachedToken();
    print(authToken);
    if (authToken != null) {
      final user = await getUserWithToken(authToken);
      emit(Authenticated(user));
    } else {
      emit(Authanticating());
    }
  }

  void _onSendOtp(SendOtp event, Emitter<AuthState> emit) async {
    await Future.delayed(Duration(milliseconds: 500));
    sendOtp(event.phone);

    emit(OtpSent(event.phone));
  }

  void _onVerifyOtp(VerifyOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await Future.delayed(Duration(milliseconds: 500));

    bool verified = await verifyOtp(event.phone, event.otp);

    try {
      if (verified) {
        User user = await loginOrSignup(event.phone);
        saveToken(user.token);
        emit(Authenticated(user));
      } else {
        emit(OTPVerifyError(event.phone));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
