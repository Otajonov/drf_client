import '../config/const.dart';

enum AuthType {drfBuiltIn, drfBuiltInOauth, simpleJWT, oauthToolkit}

class OauthConfig{

  String clientId;
  String clientSecret;
  String? authorizationEndpointUrl;
  List<String>? scopes;
  String? redirectUri;
  String? redirectScheme;

  OauthConfig({
    required this.clientId,
    required this.clientSecret,
    this.authorizationEndpointUrl,
    this.scopes,
    this.redirectUri,
    this.redirectScheme
  });
}

class DrfConfig {
  String baseUrl;
  String? tokenUrl;
  String? refreshTokenUrl;
  String? logoutUrl;
  String usernameField;
  String passwordField;
  String refreshField;
  AuthType authType;
  OauthConfig? oauthConfig;

  DrfConfig({
    required this.baseUrl,
    this.tokenUrl,
    this.refreshTokenUrl,
    this.logoutUrl,
    this.usernameField = kDefaultUsernameField,
    this.passwordField = kDefaultPasswordField,
    this.refreshField = kRefreshField,
    this.authType = AuthType.drfBuiltIn,
    this.oauthConfig
  });
}
