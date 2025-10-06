import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PageInitial extends AuthEvent {}

class SendOtp extends AuthEvent {
  final String phone;
  SendOtp(this.phone);

  @override
  List<Object?> get props => [phone];
}

class VerifyOtp extends AuthEvent {
  final String phone;
  final String otp;
  VerifyOtp(this.phone, this.otp);

  @override
  List<Object?> get props => [phone, otp];
}
