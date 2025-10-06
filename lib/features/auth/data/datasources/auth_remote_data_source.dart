import 'dart:math';

import 'package:dio/dio.dart';
import 'package:sewingaiapp/features/auth/domain/entities/user.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sewingaiapp/core/utils/constants.dart' as ENV;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phone);
  Future<bool> verifyOtp(String phone, String code);
  Future<auth.User> getUserWithToken(SupabaseClient client, String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> sendOtp(String phone) async {
    int min = 10000;
    int max = 99999;
    int otp = Random().nextInt(max - min + 1) + min;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('otp', otp);

    Dio dio = Dio();
    var response = await dio.get(
      'https://login.niazpardaz.ir/SMSInOutBox/SendSms',
      queryParameters: {
        'userName': ENV.NIAZPARDAZ_USERNAME,
        'password': ENV.NIAZPARDAZ_PASSWORD,
        'from': '10009611',
        'to': phone,
        // 'text': 'کد تایید شما: ${otp}\nلغو۱۱',
        'text': '''کد تایید شما: ${otp}\nمربی هوشمند خیاطی\nلغو11''',
      },
    );
    print(response);
  }

  @override
  Future<bool> verifyOtp(String phone, String code) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print(code);
    print(prefs.getInt('otp'));

    return code == prefs.getInt('otp').toString();
  }

  @override
  Future<auth.User> getUserWithToken(
    SupabaseClient client,
    String token,
  ) async {
    final user_response = await client
        .from('users')
        .select()
        .eq('token', token)
        .single();

    auth.User user = auth.User.fromJson(user_response);
    return user;
  }
}
