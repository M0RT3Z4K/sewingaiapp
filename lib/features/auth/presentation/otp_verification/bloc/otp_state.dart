import 'package:equatable/equatable.dart';
import 'package:sewingaiapp/features/auth/domain/entities/user.dart';

abstract class OtpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OtpInitial extends OtpState {}

class OtpLoading extends OtpState {}

class OtpVerified extends OtpState {
  final User user;
  OtpVerified(this.user);

  @override
  List<Object?> get props => [user];
}

class OtpError extends OtpState {
  final String message;
  OtpError(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpResent extends OtpState {}
