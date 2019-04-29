part of id4me_api;

///
/// Representing the id4me data and the login hint
///
class Id4meDnsDataWithLoginHint {
  /// The dns data
  Id4meDnsData id4meDnsData;

  /// The login domain name;
  String loginHint;

  Id4meDnsDataWithLoginHint(this.id4meDnsData, this.loginHint);
}
