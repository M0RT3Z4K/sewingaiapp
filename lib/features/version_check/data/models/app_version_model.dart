import 'package:sewingaiapp/features/version_check/domain/entities/app_version.dart';

class AppVersionModel extends AppVersion {
  const AppVersionModel({
    required super.latestVersion,
    required super.downloadLink,
    required super.isForced,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      latestVersion: json['latest_version'] as String,
      downloadLink: json['downloadLink'] as String,
      isForced: json['isForced'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latest_version': latestVersion,
      'downloadLink': downloadLink,
      'isForced': isForced,
    };
  }
}
