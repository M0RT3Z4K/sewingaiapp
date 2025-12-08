import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class VerifyOtpEvent extends OtpEvent {
  final String phone;
  final String otp;

  VerifyOtpEvent(this.phone, this.otp);

  @override
  List<Object?> get props => [phone, otp];
}

class ResendOtpEvent extends OtpEvent {
  final String phone;

  ResendOtpEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}
