part of id4me_api;

class Id4meSessionData {
  String identityHandle;

  /// The login name. A domain or a email.
  String id4me;
  String redirectUri = '';
  List<String> redirectUris;
  String logoUri = '';
  String loginHint = '';
  String state = 'authorize';
  String nonce;
  String scope = 'openid';
  bool standardClaimsValidated = false;
  Map<String, dynamic> bearerToken;
  String accessToken;
  String idToken;
  Map<String, dynamic> userinfo;
  Map<String, dynamic> idTokenUserinfo;
  Map<String, dynamic> accessTokenUserinfo;
  String iau;
  String iag;
  int tokenExpires = 0;
  Id4meIdentityAuthorityData iauData;

  Id4meSessionData() {
    var uuid = Uuid();
    nonce = uuid.v4();
  }
}
