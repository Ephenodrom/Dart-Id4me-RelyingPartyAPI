# Id4me Relying Party Api

Id4me Relying Party Api provides easy integration of the Id4me login into your projects. Since Id4me is still in beta, the login process can change at any time and make this package unusable!

## Table of Contents

1. [Install](#install)
   * [pubspec.yaml](#pubspec.yaml)
2. [Import](#import)
3. [Login Flow](#login-flow)
   * [Basics](#basics)
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

### Create Session Data

```dart
Id4meSessionData sessionData = await logon.createSessionData(domain, true);
```

### Build Authorization Url

```dart
String authorizationURL = logon.buildAuthorizationUrl(sessionData);
```

### Authenticate

```dart
await logon.authenticate(sessionData, code);
```

### Fetch UserInfo

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