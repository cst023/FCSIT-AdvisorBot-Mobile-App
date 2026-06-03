import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';

class ChatApiService {
  // -----------------------------------------------------------------------
  // URL CONFIGURATION 
  static const String _localUrl = 'http://192.168.0.5:8000'; // ← your LAN IP
  static const String _cloudUrl = 'YOUR_CLOUD_URL'; // ← Cloud URL
  static const bool _useCloud = false; 
  // -----------------------------------------------------------------------

  static String get baseUrl => _useCloud ? _cloudUrl : _localUrl;

  static const _timeout = Duration(seconds: 120);

  Future<ApiResponse> sendMessage(String question) async {
    final uri = Uri.parse('$baseUrl/query');

    late http.Response response;

    try {
      response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'question': question
            }),
          )
          .timeout(
            _timeout,
            onTimeout: () => throw ChatApiException(
              'The request timed out. The server may be busy — please try again.',
              type: ChatApiExceptionType.timeout,
            ),
          );
    } on ChatApiException {
      rethrow;
    } catch (e) {
      throw ChatApiException(
        'Unable to reach the server. Please check your connection.',
        type: ChatApiExceptionType.network,
      );
    }

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.fromJson(json);
      } catch (_) {
        throw ChatApiException(
          'Received an unexpected response from the server.',
          type: ChatApiExceptionType.parse,
        );
      }
    } else {
      throw ChatApiException(
        'Server returned an error (${response.statusCode}). Please try again.',
        type: ChatApiExceptionType.server,
      );
    }
  }

  /// Quick connectivity check — call this on app startup to warn the user
  /// early if the backend is unreachable (e.g. forgot to start the server).
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

enum ChatApiExceptionType { network, timeout, server, parse }

class ChatApiException implements Exception {
  final String message;
  final ChatApiExceptionType type;

  ChatApiException(this.message, {required this.type});

  @override
  String toString() => 'ChatApiException(${type.name}): $message';
}