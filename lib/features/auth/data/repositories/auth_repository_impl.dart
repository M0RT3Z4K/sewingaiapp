import 'dart:math';

import 'package:sewingaiapp/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:sewingaiapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sewingaiapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sewingaiapp/features/auth/domain/entities/user.dart' as auth;

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(
  Iterable.generate(
    length,
    (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
  ),
);

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final SupabaseClient client;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.client,
  });

  @override
  Future<void> sendOtp(String phone) async {
    return remoteDataSource.sendOtp(phone);
  }

  @override
  Future<bool> verifyOtp(String phone, String code) async {
    return remoteDataSource.verifyOtp(phone, code);
  }

  @override
  Future<auth.User> loginOrSignup(String phone) async {
    final user = await client.from('users').select().eq("phone_number", phone);
    print(user);
    if (user.isNotEmpty) {
      return auth.User.fromJson(user[0]);
    } else {
      final newUser = {
        'phone_number': phone,
        'token': getRandomString(32),
        'image_inday': '0',
        'subscription': 'normal',
        'sub_days_remain': 0,
      };
      final insertedUser = await client.from('users').insert(newUser);
      print(insertedUser);

      return auth.User.fromJson(newUser);
    }
  }

  @override
  Future<void> saveToken(String token) => localDataSource.saveToken(token);

  @override
  Future<String?> getCachedToken() => localDataSource.getCachedToken();

  @override
  Future<auth.User> getUserWithToken(String token) =>
      remoteDataSource.getUserWithToken(client, token);

  @override
  Future<void> logout() async {
    print("logout");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    final token = prefs.getString("auth_token");
    print("this is token : $token");
  }
}
