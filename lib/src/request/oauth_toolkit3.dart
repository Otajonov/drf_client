import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:drf_client/src/public/drf_config.dart';
import 'package:drf_client/src/public/drf_response.dart';
import 'package:drf_client/src/auth/oauth_toolkit.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class OauthToolkitRequest {
  final DrfConfig config;
  final String prefsKey;

  OauthToolkitRequest(this.config, this.prefsKey);

  String _makeUrl(String path) {
    String baseUrl =
        config.baseUrl.endsWith('/') ? config.baseUrl : '${config.baseUrl}/';
    String formattedPath = path.startsWith('/') ? path.substring(1) : path;
    formattedPath = (formattedPath.endsWith('/') || formattedPath.contains('?'))
        ? formattedPath
        : '$formattedPath/';
    return '$baseUrl$formattedPath';
  }

  Future<oauth2.Client> _initializeClient() async {
    final credentials = await OauthToolkitAuth().getCredentials(prefsKey);
    if (credentials != null) {
      return oauth2.Client(credentials,
          identifier: config.oauthConfig!.clientId,
          secret: config.oauthConfig!.clientSecret);
    }
    throw Exception("Not logged in or invalid OAuth credentials");
  }

  Future<DrfResponse> _performRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, File>? files,
    Map<String, String>? customHeaders,
  }) async {
    oauth2.Client client = await _initializeClient();
    String url = _makeUrl(path);
    Uri uri = Uri.parse(url);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };

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
      var request = http.Request(method, uri)
        ..headers.addAll(headers)
        ..body = bodyEncoded;

      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      //print(response.body);
      return DrfResponse.put(
        statusCode: response.statusCode,
        body: json.decode(response.body),
        httpResponse: response,
      );
    }
  }

  Future<DrfResponse> get(String path, {Map<String, String>? headers}) =>
      _performRequest(method: 'GET', path: path, customHeaders: headers);

  Future<DrfResponse> post(String path, Map<String, dynamic> body,
          {Map<String, String>? headers, Map<String, File>? files}) =>
      _performRequest(
          method: 'POST',
          path: path,
          body: body,
          files: files,
          customHeaders: headers);

  Future<DrfResponse> put(String path, Map<String, dynamic> body,
          {Map<String, String>? headers, Map<String, File>? files}) =>
      _performRequest(
          method: 'PUT',
          path: path,
          body: body,
          files: files,
          customHeaders: headers);

  Future<DrfResponse> patch(String path, Map<String, dynamic> body,
          {Map<String, String>? headers, Map<String, File>? files}) =>
      _performRequest(
          method: 'PATCH',
          path: path,
          body: body,
          files: files,
          customHeaders: headers);

  Future<DrfResponse> delete(String path, {Map<String, String>? headers}) =>
      _performRequest(method: 'DELETE', path: path, customHeaders: headers);
}
