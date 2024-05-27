import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:drf_client/src/public/drf_config.dart';
import 'package:drf_client/src/public/drf_response.dart';

class DRFBuiltInAuth {
  final String _prefsKey;

  DRFBuiltInAuth(this._prefsKey);

  Future<DrfResponse> login(DrfConfig config, String username, String password) async {
    if (config.authType != AuthType.drfBuiltIn) {
      throw Exception("AuthType.drfBuiltIn required for this method");
    } else if(config.tokenUrl == null){
      throw Exception("tokenUrl is not set in DrfConfig");
    }

    try {
      final response = await http.post(
        Uri.parse(config.tokenUrl!),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          config.usernameField: username,
          config.passwordField: password,
        }),
      );

      if (response.statusCode == 200) {
        const storage = FlutterSecureStorage();
        await storage.write(key: _prefsKey, value: response.body); // Store the raw response body
        return DrfResponse.put(statusCode: response.statusCode, body: json.decode(response.body));
      } else {
        return DrfResponse.put(statusCode: response.statusCode, body: response.body, message: "Failed to login.");
      }
    } catch (e) {
      return DrfResponse.put(statusCode: 500, message: "An error occurred during login. $e");
    }
  }

  Future<bool> logout(DrfConfig config) async {
    const storage = FlutterSecureStorage();

   if(await storage.read(key: _prefsKey) == null){
     throw Exception("User not logged in with DrfConfig that you specified");
   }

    await storage.delete(key: _prefsKey);

    if (config.logoutUrl == null) {
      return true;
    } else {

      try {
        Map<String, dynamic> tokenData = json.decode((await storage.read(key: _prefsKey))!);
        String? token = tokenData['token'];

        await http.post(
          Uri.parse(config.logoutUrl!),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );

        return true;
      } catch (e) {
        throw Exception("Error $e");
      }
    }

  }

  Future<String?> getToken() async {
    const storage = FlutterSecureStorage();
    String? tokenDetails = await storage.read(key: _prefsKey);
    if (tokenDetails != null) {
      Map<String, dynamic> tokenData = json.decode(tokenDetails);
      return tokenData['token']; // Assuming 'token' is the correct key
    }
    return null;
  }
}
