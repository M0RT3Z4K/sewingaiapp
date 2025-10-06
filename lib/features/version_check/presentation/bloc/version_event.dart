import 'package:equatable/equatable.dart';

abstract class VersionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckVersionEvent extends VersionEvent {}
