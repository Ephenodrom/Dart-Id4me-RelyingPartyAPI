import 'package:id4me_relying_party_api/id4me_relying_party_api.dart';
import "package:test/test.dart";

void main() {
  test('Test isValidUserid', () {});

  test('Test isValidClaimsParameters', () {
    Map<String, dynamic> claimsParameters = {
      "email": {"required": true, "reason": "Needed to create the profile"},
      "name": {"required": true, "reason": "Displayname in the user data"},
      "given_name": {"required": true, "reason": ""},
    };
    expect(Id4meValidator.isValidClaimsParameters(claimsParameters), true);
    claimsParameters["fullname"] = {
      "required": true,
      "reason": "Needed to create the profile"
    };
    expect(Id4meValidator.isValidClaimsParameters(claimsParameters), false);
  });
}
