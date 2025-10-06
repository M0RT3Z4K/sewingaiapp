import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sewingaiapp/features/version_check/presentation/bloc/version_event.dart';
import 'package:sewingaiapp/features/version_check/presentation/bloc/version_state.dart';
import 'package:sewingaiapp/features/version_check/domain/usecases/check_app_version.dart';

class VersionBloc extends Bloc<VersionEvent, VersionState> {
  final CheckAppVersion checkAppVersion;

  VersionBloc(this.checkAppVersion) : super(VersionInitial()) {
    on<CheckVersionEvent>(_onCheckVersion);
  }

  Future<void> _onCheckVersion(
    CheckVersionEvent event,
    Emitter<VersionState> emit,
  ) async {
    emit(VersionLoading());
    final result = await checkAppVersion();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    result.fold(
      (failure) => emit(VersionFailure(failure.message)),
      (appVersion) => emit(VersionLoadSuccess(appVersion, version)),
    );
  }
}
