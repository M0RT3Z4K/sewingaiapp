import 'package:dartz/dartz.dart';
import 'package:sewingaiapp/core/error/failures.dart';
import 'package:sewingaiapp/features/version_check/domain/entities/app_version.dart';
import 'package:sewingaiapp/features/version_check/domain/repositories/version_repository.dart';

class CheckAppVersion {
  final VersionRepository repository;

  CheckAppVersion(this.repository);

  Future<Either<Failure, AppVersion>> call() async {
    return await repository.checkVersion();
  }
}
