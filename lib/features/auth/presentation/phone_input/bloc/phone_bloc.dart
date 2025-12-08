import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/send_otp.dart';
import 'phone_event.dart';
import 'phone_state.dart';

class PhoneBloc extends Bloc<PhoneEvent, PhoneState> {
  final SendOtp sendOtp;

  PhoneBloc({required this.sendOtp}) : super(PhoneInitial()) {
    on<SendOtpEvent>(_onSendOtp);
  }

  void _onSendOtp(SendOtpEvent event, Emitter<PhoneState> emit) async {
    emit(PhoneLoading());

    try {
      await Future.delayed(Duration(milliseconds: 500));
      await sendOtp(event.phone);
      emit(PhoneOtpSent(event.phone));
    } catch (e) {
      emit(PhoneError(e.toString()));
    }
  }
}
