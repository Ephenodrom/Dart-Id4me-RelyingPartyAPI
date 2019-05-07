import 'dart:io';

import 'package:id4me_relying_party_api/id4me_relying_party_api.dart';
import 'dart:convert';

void main() async {
  Map<String, dynamic> properties = {
    Id4meConstants.KEY_CLIENT_NAME: "ID4me Demo",
    Id4meConstants.KEY_LOGO_URI:
        "https://www.androidpit.com/img/logo/favicon.png",
    Id4meConstants.KEY_REDIRECT_URI:
        "https://www.androidpit.com/id4me/demo-callback",
    Id4meConstants.KEY_DNS_RESOLVER: "8.8.8.8",
    Id4meConstants.KEY_DNSSEC_REQUIRED: false
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

  Id4meLogon logon = new Id4meLogon(
      properties: properties, claimsParameters: claimsParameters);

  print("Please enter your ID4me identifier: ");
  String domain = stdin.readLineSync();

  print("Creating session data...");
  Id4meSessionData sessionData = await logon.createSessionData(domain, true);

  print("Building authorization URL...");
  String authorizationURL = logon.buildAuthorizationUrl(sessionData);

  print("authorizationURL = $authorizationURL");

  print("Please enter the code: ");
  String code = stdin.readLineSync();

  print("Verifying code...");
  await logon.authenticate(sessionData, code);

  print("Retrieving user info...");
  Map<String, dynamic> info = await logon.fetchUserinfo(sessionData);
  print(json.encode(info));
}
