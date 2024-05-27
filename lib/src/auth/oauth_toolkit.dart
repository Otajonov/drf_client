import 'dart:async';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:drf_client/src/public/drf_config.dart';
import 'package:drf_client/src/public/drf_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OauthToolkitAuth {

  Future<DrfResponse> loginWithResourceOwner(DrfConfig config, String username, String password, String prefsKey) async {
    if (config.oauthConfig == null || config.tokenUrl == null) {
      throw Exception("OauthConfig is required for OAuth Toolkit.");
    }

    final tokenEndpoint = Uri.parse(config.tokenUrl!);
    try {
      final client = await oauth2.resourceOwnerPasswordGrant(
        tokenEndpoint,
        username,
        password,
        identifier: config.oauthConfig!.clientId,
        secret: config.oauthConfig!.clientSecret,
        scopes: config.oauthConfig!.scopes,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, client.credentials.toJson());

      return DrfResponse(statusCode: 200, body: client.credentials.toJson(), message: "Logged in success");
    } catch (e) {
      print('Error during Authorization Code flow: $e');
      return DrfResponse(statusCode: 500, message: 'Error during Resource Owner Password Credentials flow: $e');
    }
  }
  //
  // Future<DrfResponse> loginWithAuthorizationCode(DrfConfig config, String prefsKey, {List<String>? scopes}) async {
  //   if (config.oauthConfig == null) {
  //     throw Exception("OauthConfig is required for OAuth Toolkit.");
  //   }
  //
  //   final authorizationEndpoint = Uri.parse(config.oauthConfig!.authorizationEndpointUrl!);
  //   final tokenEndpoint = Uri.parse(config.tokenUrl!);
  //   final redirectUri = Uri.parse(config.oauthConfig!.redirectUri!);
  //
  //   final grant = oauth2.AuthorizationCodeGrant(
  //     config.oauthConfig!.clientId,
  //     authorizationEndpoint,
  //     tokenEndpoint,
  //     secret: config.oauthConfig!.clientSecret,
  //   );
  //
  //   final authorizationUrl = grant.getAuthorizationUrl(
  //     redirectUri,
  //     scopes: scopes ?? config.oauthConfig!.scopes,
  //   );
  //
  //   try {
  //     final resultUrl = await FlutterWebAuth2.authenticate(
  //       url: authorizationUrl.toString(),
  //       callbackUrlScheme: config.oauthConfig!.redirectScheme!,
  //     );
  //
  //     final client = await grant.handleAuthorizationResponse(Uri.parse(resultUrl).queryParameters);
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.setString(prefsKey, client.credentials.toJson());
  //
  //     return DrfResponse(statusCode: 200, body: client.credentials.toJson(), message: "Login Success");
  //   } catch (e) {
  //     print('Error during Authorization Code flow: $e');
  //     return DrfResponse(statusCode: 500, message: 'Error during Authorization Code flow: $e');
  //   }
  // }

  Future<oauth2.Credentials?> getCredentials(String prefsKey) async {
    final prefs = await SharedPreferences.getInstance();
    final storedCredentials = prefs.getString(prefsKey);
    if (storedCredentials != null) {
      final credentials = oauth2.Credentials.fromJson(storedCredentials);
      return credentials;
    }
    return null;
  }

}
