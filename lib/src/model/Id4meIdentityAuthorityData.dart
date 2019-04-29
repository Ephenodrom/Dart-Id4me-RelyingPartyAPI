part of id4me_api;

class Id4meIdentityAuthorityData {
  String iau;
  String clientId;
  String clientSecret;

  /// The openid configuration for the identity authority
  Map<String, dynamic> wellKnown;

  /// The registration data for the identity authority
  Map<String, dynamic> registrationData;

  Id4meIdentityAuthorityData({this.wellKnown});
}
