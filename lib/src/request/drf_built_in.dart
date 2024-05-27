import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:drf_client/src/public/drf_config.dart';
import 'package:drf_client/src/public/drf_response.dart';

class DrfBuiltInRequest {
  final DrfConfig config;

  DrfBuiltInRequest(this.config);

  String _makeUrl(String path) {
    String baseUrl = config.baseUrl.endsWith('/') ? config.baseUrl : '${config.baseUrl}/';
    String formattedPath = path.startsWith('/') ? path.substring(1) : path;
    formattedPath = (formattedPath.endsWith('/') || formattedPath.contains('?')) ? formattedPath : '$formattedPath/';
    return '$baseUrl$formattedPath';
  }

  Future<DrfResponse> _performRequest({
    required String method,
    required String path,
    Map<String, String>? customHeaders,
    Map<String, dynamic>? body,
    Map<String, File>? files,
    String? token,
  }) async {
    http.Response response;
    try {
      String url = _makeUrl(path);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      };

      // Merge custom headers with default headers if provided
      if (customHeaders != null) {
        headers.addAll(customHeaders);
      }

      Uri uri = Uri.parse(url);

      if (files != null && files.isNotEmpty) {

        print(files.toString());
        // If files are provided, use multipart request
        var request = http.MultipartRequest(method.toUpperCase(), uri);
        request.headers.addAll(headers);
        if (body != null) {
          request.fields.addAll(body.map((key, value) => MapEntry(key, value.toString())));
        }
        files.forEach((fieldName, file) {
          request.files.add(http.MultipartFile(
            fieldName,
            file.readAsBytes().asStream(),
            file.lengthSync(),
            filename: file.path.split('/').last,
          ));
        });
        var streamedResponse = await request.send();
        print("Fayl bilan ketyapman qorqma");
        response = await http.Response.fromStream(streamedResponse);
      } else {

        switch (method.toUpperCase()) {
          case 'POST':
            response = await http.post(uri, headers: headers, body: json.encode(body));
            break;
          case 'GET':
            response = await http.get(uri, headers: headers);
            break;
          case 'PUT':
            response = await http.put(uri, headers: headers, body: json.encode(body));
            break;
          case 'PATCH':
            response = await http.patch(uri, headers: headers, body: json.encode(body));
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers);
            break;
          default:
            throw Exception("Given Method not allowed");
        }

      }

      return DrfResponse.put(
        statusCode: response.statusCode,
        body: response.body.isNotEmpty ? json.decode(response.body) : {},
        httpResponse: response
      );
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  Future<DrfResponse> get(String path, {Map<String, String>? headers, String? token}) =>
      _performRequest(method: 'GET', path: path, customHeaders: headers, token: token);

  Future<DrfResponse> post(String path, Map<String, dynamic> body, {Map<String, String>? headers, String? token, Map<String, File>? files}) =>
      _performRequest(method: 'POST', path: path, body: body, customHeaders: headers, files: files, token: token);

  Future<DrfResponse> put(String path, Map<String, dynamic> body, {Map<String, String>? headers, String? token, Map<String, File>? files}) =>
      _performRequest(method: 'PUT', path: path, body: body, customHeaders: headers, files: files, token: token);

  Future<DrfResponse> patch(String path, Map<String, dynamic> body, {Map<String, String>? headers, String? token, Map<String, File>? files}) =>
      _performRequest(method: 'PATCH', path: path, body: body, customHeaders: headers, files: files, token: token);

  Future<DrfResponse> delete(String path, {Map<String, String>? headers, String? token}) =>
      _performRequest(method: 'DELETE', path: path, customHeaders: headers, token: token);
}
