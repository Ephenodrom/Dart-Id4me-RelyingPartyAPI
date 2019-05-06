# Id4me Relying Party Api

Id4me Relying Party Api provides easy integration of the Id4me login into your projects. Since Id4me is still in beta, the login process can change at any time and make this package unusable!

## Table of Contents

1. [Install](#install)
   * [pubspec.yaml](#pubspec.yaml)
2. [Import](#import)
3. [Login Flow](#login-flow)
   * [Basics](#basics)
   * [Create login service](#create-login-service)
   * [Create Session Data](#create-session-data)
   * [Build Authorization Url](#build-authorization-url)
   * [Authenticate](#authenticate)
   * [Fetch UserInfo](#fetch-userinfo)
4. [Changelog](#changelog)
5. [Copyright and license](#copyright-and-license)

## Install

### pubspec.yaml

Update pubspec.yaml and add the following line to your dependencies.

```yaml
dependencies:
  id4me_relying_party_api: ^0.2.0
```

## Import

Import the package with :

```dart
import 'package:id4me_relying_party_api/id4me_relying_party_api.dart';
```

## Login Flow

### Basics

The main class used is the [Id4meLogon](/lib/src/Id4meLogon.dart) class. The package also contains many more classes that are used by the Id4meLogon class. View the [Example](/example/main.dart) for a detailed example on how to use the Id4meLogon.

### Create login service

The first step in the login flow is to create an instance of the login service class [Id4meLogon](/lib/src/Id4meLogon.dart) with the necessery properties and [Id4meClaimsParameters](/lib/src/model/Id4meClaimsParameters.dart).

```dart

Map<String, dynamic> properties = {
    Id4meConstants.KEY_CLIENT_NAME: "ID4me Login Demo",
    Id4meConstants.KEY_LOGO_URI: "https://domain.com/favicon.png",
    Id4meConstants.KEY_REDIRECT_URI: "https://domain.com/redirect"
};

Id4meClaimsParameters claimsParameters = new Id4meClaimsParameters();
  claimsParameters.entries.add(Entry("email", true, "Needed to create the profile"));

Id4meLogon logon = new Id4meLogon(properties: properties, claimsParameters: claimsParameters);
```

### Create Session Data

The next step is to create the session data, that is needed throughout the hole login process. It fetches for example the DNS data and identity authority data.

```dart
Id4meSessionData sessionData = await logon.createSessionData(domain, true);
```

### Build Authorization Url

The data from the DNS can now be used to create an authentication url to which the user is routed.

```dart
String authorizationURL = logon.buildAuthorizationUrl(sessionData);
```

### Authenticate

After the user has been redirected by the *Identity Authority*, the code, given as a query parameter in the redirect url, can be used to authorize with the *Identity Agent*.

The redirect url could look like this : <https://domain.com/redirect?code=DKYPkDfkH0cLw3_NmS6IGQ.BPA4gUtfLh0gljqQ3wJNVw&state=authorize>

```dart
await logon.authenticate(sessionData, code);
```

### Fetch UserInfo

After successful authorization, the requested user data can be queried.

```dart
Map<String, dynamic> info = await logon.fetchUserinfo(sessionData);
```

## Changelog

For a detailed changelog, see the [CHANGELOG.md](CHANGELOG.md) file

## Copyright and license

MIT License

Copyright (c) 2019 Ephenodrom

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.