// import 'package:drf_client/drf_client.dart';
// import 'package:drf_client/src/auth/drf_built_in.dart';
// import 'package:drf_client/src/request/drf_built_in.dart';
// import 'package:drf_client/src/request/oauth_toolkit.dart';
// import 'package:oauth2/oauth2.dart' as oauth2;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:drf_client/src/auth/oauth_toolkit.dart';
//
// class DrfClient {
//   static final DrfClient _instance = DrfClient._internal();
//   factory DrfClient() => _instance;
//   DrfClient._internal();
//
//   final Map<String, DrfConfig> _configs = {};
//   DrfConfig? _defaultConfig;
//   String? _defaultConfigKey;
//
//   void addConfig(String key, DrfConfig config, {bool setAsDefault = false}) {
//     _configs[key] = config;
//     if (setAsDefault || (_defaultConfig == null && _defaultConfigKey == null)) {
//       _defaultConfig = config;
//       _defaultConfigKey = key;
//     }
//   }
//
//   void removeConfig(String key) {
//     if (_configs.containsKey(key)) {
//       bool wasDefault = _defaultConfigKey == key;
//       _configs.remove(key);
//       if (wasDefault) {
//         if (_configs.isNotEmpty) {
//           _defaultConfigKey = _configs.keys.first;
//           _defaultConfig = _configs[_defaultConfigKey];
//         } else {
//           _defaultConfig = null;
//           _defaultConfigKey = null;
//         }
//       }
//     }
//   }
//
//   DrfConfig? getConfig(String key) => _configs[key];
//
//   void setDefaultConfig(String key) {
//     if (_configs.containsKey(key)) {
//       _defaultConfig = _configs[key];
//       _defaultConfigKey = key;
//     } else {
//       throw Exception("DrfConfig with key $key does not exist.");
//     }
//   }
//
//   DrfConfig? get defaultConfig => _defaultConfig;
//
//
//
//
//
//
//
//
//   Future<oauth2.Client?> getOauth2Client({String? configKey}) async {
//
//     String? useKey = configKey ?? _defaultConfigKey;
//     if (useKey == null || !_configs.containsKey(useKey)) {
//       return null;
//     }
//     DrfConfig config = _configs[useKey]!;
//
//     final credentials = await OauthToolkitAuth().getCredentials(useKey);
//     if (credentials != null) {
//       final client = oauth2.Client(credentials, identifier: config.oauthConfig!.clientId, secret: config.oauthConfig!.clientSecret);
//       return client;
//     }
//     return null;
//   }
//
//
//
//
//
//
//
//
// //////////////////////////////////////////////////////////////////////////////////
//   Future<DrfResponse> loginWithResourceOwnerPassword(String username, String password, {String? configKey}) async {
//     String? useKey = configKey ?? _defaultConfigKey;
//     if (useKey == null || !_configs.containsKey(useKey)) {
//       throw Exception("DrfConfig configuration not found");
//     }
//     DrfConfig config = _configs[useKey]!;
//     return await OauthToolkitAuth().loginWithResourceOwner(config, username, password, useKey);
//   }
//
//   Future<DrfResponse> loginWithAuthorizationCode({String? configKey, List<String>? scopes}) async {
//     String? useKey = configKey ?? _defaultConfigKey;
//     if (useKey == null || !_configs.containsKey(useKey)) {
//       throw Exception("DrfConfig configuration not found");
//     }
//     DrfConfig config = _configs[useKey]!;
//     var res = await OauthToolkitAuth().loginWithAuthorizationCode(config, useKey);
//     return res;
//   }
//
//   Future<DrfResponse> login(String username, String password, {String? configKey}) async {
//
//     String? useKey = configKey ?? _defaultConfigKey;
//     if (useKey == null || !_configs.containsKey(useKey)) {
//       throw Exception("DrfConfig not fount with specified key");
//     }
//     DrfConfig config = _configs[useKey]!;
//
//     return DRFBuiltInAuth(useKey).login(config, username, password);
//   }
//
//   Future<bool> logout({String? configKey}) async {
//     String? useKey = configKey ?? _defaultConfigKey;
//     if (useKey == null || !_configs.containsKey(useKey)) {
//       throw Exception("DrfConfig not fount with specified key");
//     }
//     DrfConfig config = _configs[useKey]!;
//     if(config.authType == AuthType.oauthToolkit){
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.remove(useKey);
//       return true;
//     }
//     await DRFBuiltInAuth(useKey).logout(config);
//     return true;
//   }
//
//   Future<bool> isLoggedIn({String? configKey}) async {
//     String? useKey = configKey ?? _defaultConfigKey;
//     if (useKey == null || !_configs.containsKey(useKey)) {
//       return false;
//     }
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(useKey) != null;
//   }
// ////////////////////////////////////////////////////////////////////////////////////////
//
//
//
//
//   Future<String?> _getAuthToken({String? configKey}) async {
//     String? useKey = configKey ?? _defaultConfigKey;
//     if (useKey == null) return null;
//     return await DRFBuiltInAuth(useKey).getToken();
//   }
//
//   // Wrappers for HTTP methods
//   Future<DrfResponse> get(String path, {Map<String, String>? headers, bool includeAuth = true, String? configKey}) async {
//     return await _requestWrapper('GET', path, null, headers, includeAuth, configKey);
//   }
//
//   Future<DrfResponse> post(String path, Map<String, dynamic> body, {Map<String, String>? headers, bool includeAuth = true, String? configKey}) async {
//     return await _requestWrapper('POST', path, body, headers, includeAuth, configKey);
//   }
//
//   Future<DrfResponse> put(String path, Map<String, dynamic> body, {Map<String, String>? headers, bool includeAuth = true, String? configKey}) async {
//     return await _requestWrapper('PUT', path, body, headers, includeAuth, configKey);
//   }
//
//   Future<DrfResponse> patch(String path, Map<String, dynamic> body, {Map<String, String>? headers, bool includeAuth = true, String? configKey}) async {
//     return await _requestWrapper('PATCH', path, body, headers, includeAuth, configKey);
//   }
//
//   Future<DrfResponse> delete(String path, {Map<String, String>? headers, bool includeAuth = true, String? configKey}) async {
//     return await _requestWrapper('DELETE', path, null, headers, includeAuth, configKey);
//   }
//
//   Future<DrfResponse> _requestWrapper(String method, String path, Map<String, dynamic>? body, Map<String, String>? headers, bool includeAuth, String? configKey) async {
//
//     String? useKey = configKey ?? _defaultConfigKey;
//     if (useKey == null || !_configs.containsKey(useKey)) {
//       throw Exception("No DrfConfig configuration found. Did you forget to add it?");
//     }
//     DrfConfig config = _configs[useKey]!;
//
//
//     String? token;
//     if (includeAuth && config.authType != AuthType.oauthToolkit) {
//
//       if(config.tokenUrl != null){
//         token = await _getAuthToken(configKey: useKey);
//         if (token == null) {
//           throw Exception("User is not logged in but includeAuth set to true");
//         }
//       } else {
//         print("You didn't specify tokenUrl in DrfConfig, so I request without Authorization despite includeAuth = true");
//       }
//
//     }
//
//
//
//     if(config.authType == AuthType.oauthToolkit){
//       OauthToolkitRequest oauthToolkitRequest = OauthToolkitRequest(config, useKey);
//       switch (method) {
//         case 'GET':
//           return oauthToolkitRequest.get(path, headers: headers);
//         case 'POST':
//           return oauthToolkitRequest.post(path, body!, headers: headers);
//         case 'PUT':
//           return oauthToolkitRequest.put(path, body!, headers: headers);
//         case 'PATCH':
//           return oauthToolkitRequest.patch(path, body!, headers: headers);
//         case 'DELETE':
//           return oauthToolkitRequest.delete(path, headers: headers);
//         default:
//           return DrfResponse.put(statusCode: 405, message: "Invalid HTTP method.");
//       }
//
//
//     } else {
//
//       DrfBuiltInRequest builtInRequest = DrfBuiltInRequest(config);
//       switch (method) {
//         case 'GET':
//           return builtInRequest.get(path, headers: headers, token: token);
//         case 'POST':
//           return builtInRequest.post(path, body!, headers: headers, token: token);
//         case 'PUT':
//           return builtInRequest.put(path, body!, headers: headers, token: token);
//         case 'PATCH':
//           return builtInRequest.patch(path, body!, headers: headers, token: token);
//         case 'DELETE':
//           return builtInRequest.delete(path, headers: headers, token: token);
//         default:
//           return DrfResponse.put(statusCode: 405, message: "Invalid HTTP method.");
//       }
//
//     }
//
//
//
//
//
//
//   }
// }
