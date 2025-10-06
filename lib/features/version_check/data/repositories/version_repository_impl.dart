import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sewingaiapp/core/error/failures.dart';
import 'package:sewingaiapp/features/version_check/domain/entities/app_version.dart';
import 'package:sewingaiapp/features/version_check/domain/repositories/version_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VersionRepositoryImpl implements VersionRepository {
  final SupabaseClient supabase;

  VersionRepositoryImpl({required this.supabase});

  @override
  Future<Either<Failure, AppVersion>> checkVersion() async {
    final response = await supabase.from('update_links').select();

    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;

    await supabase.from('opens').insert({
      'device': '${allInfo['host']}-${allInfo['id']}',
    });

    final app_version = AppVersion(
      latestVersion: response[0]['latestVersion'],
      downloadLink: response[0]['downloadLink'],
      isForced: response[0]['isForced'],
    );

    if (response.isNotEmpty) {
      return Right(app_version);
    } else {
      throw Exception('Failed to fetch version info');
    }
  }
}
