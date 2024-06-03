import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:drf_client/src/public/drf_config.dart';
import 'package:drf_client/src/public/drf_response.dart';

class DrfBuiltInRequest {
  final DrfConfig config;

  DrfBuiltInRequest(this.config);

  String _makeUrl(String path) {
    String baseUrl =
        config.baseUrl.endsWith('/') ? config.baseUrl : '${config.baseUrl}/';
    String formattedPath = path.startsWith('/') ? path.substring(1) : path;
    formattedPath = (formattedPath.endsWith('/') || formattedPath.contains('?'))
        ? formattedPath
        : '$formattedPath/';
    return '$baseUrl$formattedPath';
  }

  Future<DrfResponse> _performRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, File>? files,
    Map<String, String>? customHeaders,
    String? token,
  }) async {
    String url = _makeUrl(path);
    Uri uri = Uri.parse(url);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    if (files != null && files.isNotEmpty) {
      var request = http.MultipartRequest(method.toUpperCase(), uri)
        ..headers.addAll(headers);

      for (var entry in files.entries) {
        request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path));
      }

      body?.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      var streamedResponse = await request.send();
      return DrfResponse.put(
        statusCode: streamedResponse.statusCode,
        streamedResponse: streamedResponse,
      );
    } else {
      var bodyEncoded = json.encode(body);
      http.Response httpResponse;

      switch (method.toUpperCase()) {
        case 'POST':
          httpResponse =
              await http.post(uri, headers: headers, body: bodyEncoded);
          break;
        case 'PUT':
          httpResponse =
              await http.put(uri, headers: headers, body: bodyEncoded);
          break;
        case 'PATCH':
          httpResponse =
              await http.patch(uri, headers: headers, body: bodyEncoded);
          break;
        default:
          throw Exception("HTTP method $method not supported");
      }

      return DrfResponse.put(
        statusCode: httpResponse.statusCode,
        httpResponse: httpResponse,
        body: json.decode(httpResponse.body),
      );
    }
  }

  Future<DrfResponse> get(String path,
          {Map<String, String>? headers, String? token}) =>
      _performRequest(
          method: 'GET', path: path, customHeaders: headers, token: token);

  Future<DrfResponse> post(String path, Map<String, dynamic> body,
          {Map<String, String>? headers,
          String? token,
          Map<String, File>? files}) =>
      _performRequest(
          method: 'POST',
          path: path,
          body: body,
          files: files,
          customHeaders: headers,
          token: token);

  Future<DrfResponse> put(String path, Map<String, dynamic> body,
          {Map<String, String>? headers,
          String? token,
          Map<String, File>? files}) =>
      _performRequest(
          method: 'PUT',
          path: path,
          body: body,
          files: files,
          customHeaders: headers,
          token: token);

  Future<DrfResponse> patch(String path, Map<String, dynamic> body,
          {Map<String, String>? headers,
          String? token,
          Map<String, File>? files}) =>
      _performRequest(
          method: 'PATCH',
          path: path,
          body: body,
          files: files,
          customHeaders: headers,
          token: token);

  Future<DrfResponse> delete(String path,
          {Map<String, String>? headers, String? token}) =>
      _performRequest(
          method: 'DELETE', path: path, customHeaders: headers, token: token);
}
