import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sewingaiapp/core/utils/constants.dart' as ENV;

class ApiClient {
  final Dio _dio;

  ApiClient({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? "https://openrouter.ai/api/v1",
          connectTimeout: const Duration(seconds: 25),
          receiveTimeout: const Duration(seconds: 25),
        ),
      );

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Response> post(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _dio.post(
        endpoint,
        options: Options(
          headers: {
            "Authorization": ENV.OPENROUTER_AUTH,
            "Content-Type": "application/json",
          },
        ),

        data: jsonEncode({
          "model": "google/gemini-2.5-flash-lite",
          "messages": [
            {
              "role": "system",
              "content": [
                {
                  "type": "text",
                  "text":
                      '''You are a professional Sewing Assistant. and answer persian''',
                },
              ],
            },
            {
              'role': 'user',

              'content': data['base64image'] != null
                  ? [
                      {"type": "text", "text": data['prompt']},
                      {
                        'type': 'image_url',

                        'image_url': {
                          'url':
                              'data:image/jpeg;base64,' + data['base64image'],
                        },
                      },
                    ]
                  : [
                      {"type": "text", "text": data['prompt']},
                    ],
            },
          ],
        }),
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return "Connection Timeout";
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return "Receive Timeout";
    } else if (e.type == DioExceptionType.badResponse) {
      return "Server Error: ${e.response?.statusCode}";
    } else {
      return "Unexpected Error: ${e.message}";
    }
  }
}
