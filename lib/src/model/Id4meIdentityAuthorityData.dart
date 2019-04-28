part of id4me_api;

class Id4meIdentityAuthorityData {
  String iau;
  String clientId;
  String clientSecret;
  Map<String, dynamic> wellKnown;
  Map<String, dynamic> registrationData;

  Id4meIdentityAuthorityData({this.wellKnown});
}
