import 'dart:io';

import 'package:id4me_relying_party_api/id4me_relying_party_api.dart';
import 'dart:convert';

void main() async {
  var properties = {
    Id4meConstants.KEY_CLIENT_NAME: 'ID4me Demo',
    Id4meConstants.KEY_LOGO_URI:
        'https://www.androidpit.com/img/logo/favicon.png',
    Id4meConstants.KEY_REDIRECT_URI:
        'https://www.androidpit.com/id4me/demo-callback',
    Id4meConstants.KEY_DNS_RESOLVER: '8.8.8.8',
    Id4meConstants.KEY_DNSSEC_REQUIRED: false
  };

  var claimsParameters = {
    Id4meConstants.KEY_CLAIM_EMAIL: {
      'required': true,
      'reason': 'Needed to create the profile'
    },
    Id4meConstants.KEY_CLAIM_NAME: {
      'required': true,
      'reason': 'Displayname in the user data'
    },
    Id4meConstants.KEY_CLAIM_GIVEN_NAME: {'required': true, 'reason': ''},
  };

  var logon =
      Id4meLogon(properties: properties, claimsParameters: claimsParameters);

  print('Please enter your ID4me identifier: ');
  var domain = stdin.readLineSync();

  print('Creating session data...');

  Id4meSessionData sessionData;
  try {
    sessionData = await logon.createSessionData(domain, true);
  } on DnsResolveException {
    // Handle dns resolving exception
  } on IdentityAuthorityDataFetchException {
    // Handle Identity Authority data fetch exception
  } on Id4meIdentifierFormatException {
    // Handle Id4meIdentifierFormatException
  } catch (e) {
    // Handle any other exception
  }

  print('Building authorization URL...');
  var authorizationURL = logon.buildAuthorizationUrl(sessionData);

  print('authorizationURL = $authorizationURL');

  print('Please enter the code: ');
  var code = stdin.readLineSync();

  print('Verifying code...');
  try {
    await logon.authenticate(sessionData, code);
  } on BearerTokenFetchException {
    // Handle error while fetching bearer token
  } on BearerTokenNotFoundException {
    // Handle missing bearer token
  } catch (e) {
    // Handle any other exception
  }

  print('Retrieving user info...');
  Map<String, dynamic> info;
  try {
    info = await logon.fetchUserinfo(sessionData);
  } on MandatoryClaimsException {
    // Handle missing mandatory claims
  } on UserInfoFetchException {
    // Handle user info fetch exception
  } catch (e) {
    // Handle any other exception
  }
  print(json.encode(info));
}
