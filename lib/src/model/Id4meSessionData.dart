part of id4me_api;

class Id4meSessionData {
  String identityHandle;
  String id4me = null;
  String redirectUri = "";
  List<String> redirectUris = null;
  String logoUri = "";
  String loginHint = "";
  String state = "authorize";
  String nonce;
  String scope = "openid";
  bool standardClaimsValidated = false;
  Map<String, dynamic> bearerToken = null;
  String accessToken = null;
  String idToken = null;
  Map<String, dynamic> userinfo = null;
  Map<String, dynamic> idTokenUserinfo = null;
  Map<String, dynamic> accessTokenUserinfo = null;
  String iau = null;
  String iag = null;
  int tokenExpires = 0;
  Id4meIdentityAuthorityData iauData;

  Id4meSessionData() {
    Uuid uuid = new Uuid();
    nonce = uuid.v4();
  }
}
