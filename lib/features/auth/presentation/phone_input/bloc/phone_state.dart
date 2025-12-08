import 'package:equatable/equatable.dart';

abstract class PhoneState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PhoneInitial extends PhoneState {}

class PhoneLoading extends PhoneState {}

class PhoneOtpSent extends PhoneState {
  final String phone;
  PhoneOtpSent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class PhoneError extends PhoneState {
  final String message;
  PhoneError(this.message);

  @override
  List<Object?> get props => [message];
}
