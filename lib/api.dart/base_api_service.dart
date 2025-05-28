import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/api_exception.dart';

class BaseApiService {
  final String baseUrl;

  BaseApiService({required this.baseUrl});

  Future<dynamic> handleResponse(http.Response response, String operation) async {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isNotEmpty ? json.decode(response.body) : null;
      }

      throw ApiException.fromResponse(response.statusCode, response.body);
    } on FormatException {
      throw ApiException(
        message: 'Geçersiz yanıt formatı',
        details: 'İşlem: $operation',
      );
    } on SocketException {
      throw ApiException.networkError();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Beklenmeyen hata',
        details: e.toString(),
      );
    }
  }
}