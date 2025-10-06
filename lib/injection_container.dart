import 'package:get_it/get_it.dart';
import 'package:sewingaiapp/core/network/api_client.dart';
import 'package:sewingaiapp/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sewingaiapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sewingaiapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/get_cached_token.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/get_user_with_token.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/login_or_signup.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/logout.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/save_token.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/send_otp.dart';
import 'package:sewingaiapp/features/auth/domain/usecases/verify_otp.dart';
import 'package:sewingaiapp/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:sewingaiapp/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/get_current_user.dart';
import 'package:sewingaiapp/features/chat/domain/usecases/send_message.dart';
import 'package:sewingaiapp/features/version_check/data/repositories/version_repository_impl.dart';
import 'package:sewingaiapp/features/version_check/domain/usecases/check_app_version.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Supabase client

  getIt.registerSingleton(Supabase.instance.client);

  // Version
  getIt.registerSingleton(VersionRepositoryImpl(supabase: getIt()));
  getIt.registerSingleton(CheckAppVersion(getIt<VersionRepositoryImpl>()));

  // Chat
  getIt.registerSingleton(ApiClient());
  getIt.registerSingleton(ChatRemoteDataSourceImpl(getIt(), getIt()));
  getIt.registerSingleton(
    ChatRepositoryImpl(getIt<ChatRemoteDataSourceImpl>()),
  );
  getIt.registerSingleton(SendMessage(getIt<ChatRepositoryImpl>()));
  getIt.registerSingleton(SendImgMessage(getIt<ChatRepositoryImpl>()));
  getIt.registerSingleton(GetCurrentUser(getIt<ChatRepositoryImpl>()));

  // Auth
  getIt.registerSingleton(AuthRemoteDataSourceImpl());
  getIt.registerSingleton(AuthLocalDataSourceImpl());
  getIt.registerSingleton(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSourceImpl>(),
      localDataSource: getIt<AuthLocalDataSourceImpl>(),
      client: getIt(),
    ),
  );
  getIt.registerSingleton(GetCachedToken(getIt<AuthRepositoryImpl>()));
  getIt.registerSingleton(LoginOrSignup(getIt<AuthRepositoryImpl>()));
  getIt.registerSingleton(SaveToken(getIt<AuthRepositoryImpl>()));
  getIt.registerSingleton(SendOtp(getIt<AuthRepositoryImpl>()));
  getIt.registerSingleton(VerifyOtp(getIt<AuthRepositoryImpl>()));
  getIt.registerSingleton(GetUserWithToken(getIt<AuthRepositoryImpl>()));
  getIt.registerSingleton(Logout(getIt<AuthRepositoryImpl>()));
}
