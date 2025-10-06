import 'package:dartz/dartz.dart';
import 'package:sewingaiapp/core/error/failures.dart';
import 'package:sewingaiapp/features/version_check/domain/entities/app_version.dart';

abstract class VersionRepository {
  Future<Either<Failure, AppVersion>> checkVersion();
}
