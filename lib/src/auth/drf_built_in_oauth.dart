import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:drf_client/src/public/drf_config.dart';
import 'package:drf_client/src/public/drf_response.dart';
import 'package:url_launcher/url_launcher.dart';

class DRFBuiltInOauth {
  final String _prefsKey;
  final AppLinks _appLinks;

  DRFBuiltInOauth(this._prefsKey) : _appLinks = AppLinks();

  Future<DrfResponse> login(DrfConfig config) async {
    if (config.authType != AuthType.drfBuiltInOauth) {
      throw Exception("AuthType.drfBuiltInOauth required for this method");
    }
    if (config.oauthConfig == null) {
      throw Exception("OauthConfig is not set in DrfConfig");
    }
    if (config.oauthConfig!.authorizationEndpointUrl == null) {
      throw Exception("Authorization Url is not set in OauthConfig");
    }
    if (config.oauthConfig!.redirectScheme == null) {
      throw Exception("Redirect Uri Scheme is not set in OauthConfig");
    }

    Completer<DrfResponse> completer = Completer<DrfResponse>();

    try {
      await launchUrl(Uri.parse("${config.oauthConfig!.authorizationEndpointUrl!}?scheme=${config.oauthConfig!.redirectScheme!}"), mode: LaunchMode.inAppBrowserView);

      _appLinks.uriLinkStream.listen((uri) async {
        if (uri.scheme == config.oauthConfig!.redirectScheme) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          var token = uri.queryParameters['token'];
          if (token != null && token.isNotEmpty) {
            String tokenJson = jsonEncode({'token': token});
            await prefs.setString(_prefsKey, tokenJson);
            completer.complete(DrfResponse(statusCode: 200, body: tokenJson, message: "Login Success"));
          } else {
            completer.completeError(Exception("No token provided in redirect uri"));
          }
        } else {
          completer.completeError(Exception("Unexpected URI scheme received: ${uri.scheme}"));
        }
      });

    } catch (e) {
      throw Exception("An error occurred during login. $e");
    }

    return completer.future;
  }

  Future<bool> logout(DrfConfig config) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString(_prefsKey) == null) {
      throw Exception("User not logged in with DrfConfig that you specified");
    }

    await prefs.remove(_prefsKey);

    if (config.logoutUrl == null) {
      return true;
    } else {
      try {
        Map<String, dynamic> tokenData = json.decode(prefs.getString(_prefsKey)!);
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
        throw Exception("Error during logout: $e");
      }
    }
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenDetails = prefs.getString(_prefsKey);
    if (tokenDetails != null) {
      Map<String, dynamic> tokenData = json.decode(tokenDetails);
      return tokenData['token'];
    }
    return null;
  }
}
