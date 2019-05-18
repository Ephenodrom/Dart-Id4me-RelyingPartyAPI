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
4. [Exceptions](#exceptions)
5. [Changelog](#changelog)
6. [Copyright and license](#copyright-and-license)

## Install

### pubspec.yaml

Update pubspec.yaml and add the following line to your dependencies.

```yaml
dependencies:
  id4me_relying_party_api: ^0.5.0
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

The first step in the login flow is to create an instance of the login service class [Id4meLogon](/lib/src/Id4meLogon.dart) with the necessery properties and claimsparameter. See the [example](/example/main.dart) on how to set them up.

```dart

Map<String, dynamic> properties = {
    Id4meConstants.KEY_CLIENT_NAME: "ID4me Login Demo",
    Id4meConstants.KEY_LOGO_URI: "https://domain.com/favicon.png",
    Id4meConstants.KEY_REDIRECT_URI: "https://domain.com/redirect"
};

Map<String, dynamic> claimsParameters = {
    Id4meConstants.KEY_CLAIM_EMAIL: {
      "required": true,
      "reason": "Needed to create the profile"
    },
    Id4meConstants.KEY_CLAIM_NAME: {
      "required": true,
      "reason": "Displayname in the user data"
    },
    Id4meConstants.KEY_CLAIM_GIVEN_NAME: {"required": true, "reason": ""},
};

Id4meLogon logon = new Id4meLogon(properties: properties, claimsParameters: claimsParameters);
```

### Create Session Data

The next step is to create the session data, that is needed throughout the hole login process. It fetches for example the DNS data and identity authority data.

```dart
Id4meSessionData sessionData;
try {
  sessionData = await logon.createSessionData(domain, true);
} on DnsResolveException {
  // Handle DnsResolveException
} on IdentityAuthorityDataFetchException {
  // Handle IdentityAuthorityDataFetchException
} on Id4meIdentifierFormatException {
  // Handle Id4meIdentifierFormatException
} on DnsDataNotParseableException {
  // Handle DnsDataNotParseableException
} catch (e) {
  // Handle any other exception
}
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
try {
  await logon.authenticate(sessionData, code);
} on BearerTokenFetchException {
  // Handle BearerTokenFetchException
} on BearerTokenNotFoundException {
  // Handle BearerTokenNotFoundException
} catch (e) {
  // Handle any other exception
}
```

### Fetch UserInfo

After successful authorization, the requested user data can be queried.

```dart
Map<String, dynamic> info;
try {
  info = await logon.fetchUserinfo(sessionData);
} on MandatoryClaimsException {
  // Handle MandatoryClaimsException
} on UserInfoFetchException {
  // Handle UserInfoFetchException
} catch (e) {
  // Handle any other exception
}
```

## Exceptions

The login service can throw several id4me specific exceptions throughout the login flow. View the [example](/example/main.dart) for the right time to catch them.

### Id4meIdentifierFormatException

If the ID4me identifier has the wrong format, an [Id4meIdentifierFormatException](lib/src/model/exception/Id4meIdentifierFormatException.dart) is thrown.

### DnsResolveException

The [DnsResolveException](/lib/src/model/exception/DnsResolveException.dart) is thrown when something unexpected happens while trying to fetch the _openid TXT record for the given id4me login.

### DnsDataNotParseableException

[DnsDataNotParseableException](/lib/src/model/exception/DnsDataNotParseableException.dart) is thrown if the [Id4meDnsData](lib/src/model/Id4meDnsData.dart) could not be parsed from the dns record value.

### IdentityAuthorityDataFetchException

If it is not possible to fetch the data for configured Identity Authority, an [IdentityAuthorityDataFetchException](/lib/src/model/exception/IdentityAuthorityDataFetchException.dart) is thrown.

### BearerTokenFetchException

A [BearerTokenFetchException](/lib/src/model/exception/BearerTokenFetchException.dart) is thrown when something unexpected happens while trying to fetch the bearer token from the Idenity Agent.

### BearerTokenNotFoundException

If the response from the Idenity Agent does not contain a bearer token the [BearerTokenNotFoundException](/lib/src/model/exception/BearerTokenNotFoundException.dart) is thrown.

### UserInfoFetchException

When something unexpected happens while trying to fetch the userinfo from the Identity Agent, an [UserInfoFetchException](/lib/src/model/exception/UserInfoFetchException.dart) is thrown.

### MandatoryClaimsException

If the UserInfo does not contain all claimes that are marked as required, the [MandatoryClaimsException](/lib/src/model/exception/MandatoryClaimsException.dart) is thrown.

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
