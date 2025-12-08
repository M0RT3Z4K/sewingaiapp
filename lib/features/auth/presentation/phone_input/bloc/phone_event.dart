import 'package:equatable/equatable.dart';

abstract class PhoneEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SendOtpEvent extends PhoneEvent {
  final String phone;
  SendOtpEvent(this.phone);

  @override
  List<Object?> get props => [phone];
}
