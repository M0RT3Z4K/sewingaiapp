import 'package:equatable/equatable.dart';
import 'package:sewingaiapp/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authanticating extends AuthState {}

class OtpSent extends AuthState {
  final String phone;
  OtpSent(this.phone);

  @override
  List<Object?> get props => [phone];
}

class Authenticated extends AuthState {
  final User user;
  Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class OTPVerifyError extends AuthState {
  final String phone;
  OTPVerifyError(this.phone);

  @override
  List<Object?> get props => [phone];
}
