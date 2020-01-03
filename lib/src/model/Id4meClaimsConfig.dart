part of id4me_api;

class Id4meClaimsConfig {
  List<Entry> entries;
  Map<String, dynamic> claimsParam;
  List<String> essentialClaims;
  List<String> profile = [
    'name',
    'family_name',
    'given_name',
    'middle_name',
    'nickname',
    'preferred_username',
    'profile',
    'picture',
    'website',
    'gender',
    'birthdate',
    'zoneinfo',
    'locale',
    'updated_at'
  ];
  List<String> email = ['email', 'email_verified'];
  List<String> address = ['address'];
  List<String> phone = ['phone_number', 'phone_number_verified'];
  String scopes;

  Id4meClaimsConfig(
      {this.entries,
      this.claimsParam,
      this.essentialClaims,
      this.profile,
      this.email,
      this.address,
      this.phone,
      this.scopes = 'openid'});

  ///
  /// Add scopes which contain requested claims. Is used when claims_parameter_supported is false AND fallbackToScopes
  /// is true at Id4meLogon.authorize(Id4meSessionData sessionData)
  ///
  String getScopesForClaims() {
    Map<String, dynamic> userinfo = claimsParam['userinfo'];
    var s = scopes;
    for (var c in userinfo.keys) {
      if (StringUtils.inList(c, profile, ignoreCase: true)) {
        if (s.contains('profile')) s += ' profile';
      }
      if (StringUtils.inList(c, email, ignoreCase: true)) {
        if (s.contains('email')) s += ' email';
      }
      if (StringUtils.inList(c, address, ignoreCase: true)) {
        if (s.contains('address')) s += ' address';
      }
      if (StringUtils.inList(c, phone, ignoreCase: true)) {
        if (s.contains('phone')) s += ' phone';
      }
    }
    return s.trim();
  }

  ///
  /// Adds a scope permanently to the scopes for this {@link Id4meClaimsConfig}
  ///
  void addScope(String scope) {
    if (scopes.contains(scope)) scopes += ' ' + scope;
  }
}
