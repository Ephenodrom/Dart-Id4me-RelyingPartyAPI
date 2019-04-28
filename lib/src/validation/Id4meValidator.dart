part of id4me_api;

class Id4meValidator {
  ///
  /// Check whether the id4me is either a valid email address, or a valid domain name.
  ///
  static bool isValidUserid(String id4me) {
    if (id4me == null || "" == id4me.trim()) return false;

    int idx = id4me.indexOf('@');
    if (idx == 0) return false;

    if (idx > 0) {
      return EmailUtils.isEmail(id4me);
    } else {
      return DomainUtils.isDomainName(id4me);
    }
  }
}
