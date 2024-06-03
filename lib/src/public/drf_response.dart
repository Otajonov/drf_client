import 'dart:convert';
import 'package:http/http.dart' as http;

class DrfResponse {
  final int statusCode;
  final dynamic body;
  final http.Response? httpResponse;
  final http.StreamedResponse? streamedResponse;
  final String? message;

  DrfResponse({
    required this.statusCode,
    this.body,
    this.httpResponse,
    this.streamedResponse,
    this.message,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  String? get bodyUtf8 {
    if (httpResponse != null) {
      return utf8.decode(httpResponse!.bodyBytes);
    } else if (streamedResponse != null) {
      // This is a simplification. In reality, handling streamed responses might need async processing.
      return utf8.decode(
          streamedResponse!.stream.toBytes().asStream().toString().codeUnits);
    }
    return null;
  }

  dynamic get bodyDecoded {
    try {
      return json.decode(bodyUtf8!);
    } catch (e) {
      return null;
    }
  }

  factory DrfResponse.put(
      {required int statusCode,
      dynamic body,
      http.Response? httpResponse,
      http.StreamedResponse? streamedResponse,
      String? message}) {
    return DrfResponse(
        statusCode: statusCode,
        body: body,
        httpResponse: httpResponse,
        streamedResponse: streamedResponse,
        message: message);
  }
}
