import 'package:equatable/equatable.dart';
import 'package:sewingaiapp/features/version_check/domain/entities/app_version.dart';

abstract class VersionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VersionInitial extends VersionState {}

class VersionLoading extends VersionState {}

class VersionLoadSuccess extends VersionState {
  final AppVersion appVersion;
  final Version;

  VersionLoadSuccess(this.appVersion, this.Version);

  @override
  List<Object?> get props => [appVersion, Version];
}

class VersionFailure extends VersionState {
  final String message;

  VersionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
