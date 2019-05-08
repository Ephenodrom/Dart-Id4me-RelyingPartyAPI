part of id4me_api;

///
/// Validator for Id4me data
///
class Id4meValidator {
  static List<String> validClaims = [
    Id4meConstants.KEY_CLAIM_SUB,
    Id4meConstants.KEY_CLAIM_NAME,
    Id4meConstants.KEY_CLAIM_GIVEN_NAME,
    Id4meConstants.KEY_CLAIM_FAMILY_NAME,
    Id4meConstants.KEY_CLAIM_MIDDLE_NAME,
    Id4meConstants.KEY_CLAIM_NICKNAME,
    Id4meConstants.KEY_CLAIM_PREFERRED_USERNAME,
    Id4meConstants.KEY_CLAIM_PROFILE,
    Id4meConstants.KEY_CLAIM_PICTURE,
    Id4meConstants.KEY_CLAIM_WEBSITE,
    Id4meConstants.KEY_CLAIM_EMAIL,
    Id4meConstants.KEY_CLAIM_EMAIL_VERIFIED,
    Id4meConstants.KEY_CLAIM_GENDER,
    Id4meConstants.KEY_CLAIM_BIRTHDATE,
    Id4meConstants.KEY_CLAIM_ZONEINFO,
    Id4meConstants.KEY_CLAIM_LOCALE,
    Id4meConstants.KEY_CLAIM_PHONE_NUMBER,
    Id4meConstants.KEY_CLAIM_PHONE_NUMBER_VERIFIED,
    Id4meConstants.KEY_CLAIM_ADDRESS,
    Id4meConstants.KEY_CLAIM_UPDATED
  ];

  ///
  /// Check whether given String [id4me] is either a valid email address, or a valid domain name.
  ///
  static bool isValidUserid(String id4me) {
    if (id4me == null || "" == id4me.trim()) {
      return false;
    }

    int idx = id4me.indexOf('@');
    if (idx == 0) {
      return false;
    }

    if (idx > 0) {
      return EmailUtils.isEmail(id4me);
    } else {
      return DomainUtils.isDomainName(id4me);
    }
  }

  ///
  /// Check the given [claimsParameters] are valid.
  ///
  static bool isValidClaimsParameters(Map<String, dynamic> claimsParameters) {
    for (String key in claimsParameters.keys) {
      if (!validClaims.contains(key)) {
        return false;
      }
    }
    return true;
  }
}
