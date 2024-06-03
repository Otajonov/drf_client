Helps you to automatically authenticate and store tokens and refresh them, also make api requests using them.

This project is under development. View the GitHub code and contribute 👉 https://github.com/Otajonov/drf_client

## Features

- ✅ Automatically store tokens using Flutter Secure Storage
- ✅ Automatically refresh tokens
- ✅ Supports Oauth2 by Django Oauth Toolkit
- ✅ Easy REST API call with auth credentials
- ✅ More coming soon ...

## Getting started

To start using package, add it to your dependencies by running this:
```shell  
flutter pub add drf_client
```  
or add this line into your pubspec.yaml under dependencies:
```yaml
dependencies:  
  flutter:  
    sdk: flutter
  # your other dependencies ...
  
  drf_client: <latest_version>
```
Then import the package in desired files:

```dart
import 'package:drf_client/drf_client.dart'; 
```
Enjoy coding!

## Usage

Firstly, initialize the config:
```dart  

  void main() {
  
  // existing code
  
    DrfClient client = DrfClient();
    client.addConfig('your-app', DrfConfig(
      authType: AuthType.drfBuiltInAuth,
      baseUrl: 'https://your-app.com/api',
      tokenUrl: 'https://your-app.com/api/token',
      refreshTokenUrl: 'https://your-app.com/api/token/refresh',

      usernameField: 'username', // default username, change this if you are using custom user model in django
      passwordField: 'password', // def password, change this if you changed password field in you user model
      refreshField: 'refresh_token', // change this to comply with your token refresh logic if JWT used
      

      // Set this if u are using Authorization Code over Django-oauth-toolkit
      // oauthConfig: OauthConfig(
      // clientId: "",
      // clientSecret: "",
      // authorizationEndpointUrl: "https://ilmchat.com/auth/authorize/",
      // redirectScheme: 'you-app-shceme'
      //
      // )
    ));
  }
    
```  

You can also set multiple config so that you can make request and authenticate multiple django servers at the same code by giving specific app name in config.

## Authenticating users

via drfBuiltInAuth:

```dart

DrfClient client = DrfClient();

client.loginDrfBuiltIn()


```

## making requests

```dart

DrfClient client = DrfClient();

client.get() // post() put() patch() delete()


```

It will use stored user token in requests if logged in.
You can remove Token from auth header by includeToken: false