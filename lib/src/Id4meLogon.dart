part of id4me_api;

class Id4meLogon {
  String TAG = "Id4meLogon";

  //static final String UTF_8 = StandardCharsets.UTF_8.name();

  //final Id4meIdentityAuthorityStorage2 storage =Id4meIdentityAuthorityStorage2.INSTANCE;

  Id4meResolver resolver;
  String clientName;
  String redirectUri;
  List<String> redirectUris;
  String logoUri;
  String registrationDataPath;
  String dnssecRootKey;
  Id4meClaimsConfig claimsConfig;
  Id4meKeyPairHandler keyPairHandler;
  bool fallbackToScopes;
  bool logSessionData;

  Id4meLogon(
      {Map<String, dynamic> properties,
      Map<String, dynamic> claimsParameters,
      List<String> scopes,
      this.logSessionData = false}) {
    if (properties != null) {
      _readProperties(properties);
    }
    claimsConfig = new Id4meClaimsConfig(claimsParam: claimsParameters);
    if (scopes != null)
      for (String scope in scopes) {
        claimsConfig.addScope(scope);
      }

    // TODO initSSLSocketFactory();
  }

  void _readProperties(Map<String, dynamic> properties) {
    if (properties.containsKey(Id4meConstants.KEY_CLIENT_NAME)) {
      this.clientName = properties[Id4meConstants.KEY_CLIENT_NAME];
    } else {
      throw Exception("Id4meProperties.clientName not set");
    }

    if (properties.containsKey(Id4meConstants.KEY_REDIRECT_URI)) {
      this.redirectUri = properties[Id4meConstants.KEY_REDIRECT_URI];
    } else {
      throw Exception("Id4meProperties.redirectURI not set");
    }

    if (properties.containsKey(Id4meConstants.KEY_REDIRECT_URIS)) {
      this.redirectUris = properties[Id4meConstants.KEY_REDIRECT_URIS];
    } else {
      this.redirectUris = [this.redirectUri];
    }

    if (properties.containsKey(Id4meConstants.KEY_LOGO_URI)) {
      this.logoUri = properties[Id4meConstants.KEY_LOGO_URI];
    }

    if (properties.containsKey(Id4meConstants.KEY_DNS_ROOT_KEY)) {
      this.dnssecRootKey = properties[Id4meConstants.KEY_DNS_ROOT_KEY];
    } else {
      this.dnssecRootKey =
          ". IN DS 19036 8 2 49AAC11D7B6F6446702E54A1607371607A1A41855200FD2CE1CDDE32F24E8FB5";
    }

    if (properties.containsKey(Id4meConstants.KEY_REGISTRATION_DATA_PATH)) {
      this.registrationDataPath =
          properties[Id4meConstants.KEY_REGISTRATION_DATA_PATH];
    } else {
      this.registrationDataPath = "./";
    }

    String dnsResolver;
    if (properties.containsKey(Id4meConstants.KEY_DNS_RESOLVER)) {
      dnsResolver = properties[Id4meConstants.KEY_DNS_RESOLVER];
    } else {
      dnsResolver = "127.0.0.1";
    }

    //this.resolver = new Id4meResolver(dnsResolver, dnssecRootKey,
    //properties[Id4meConstants.KEY_DNSSEC_REQUIRED]);

    if (properties.containsKey(Id4meConstants.KEY_PRIVATE_KEY) &&
        properties.containsKey(Id4meConstants.KEY_PUBLIC_KEY)) {
      keyPairHandler = new Id4meKeyPairHandler(
          properties[Id4meConstants.KEY_PRIVATE_KEY],
          properties[Id4meConstants.KEY_PUBLIC_KEY]);
    }
  }

  ///
  /// Builds the authorization url.
  ///
  String buildAuthorizationUrl(Id4meSessionData sessionData) {
    Logger(TAG).info("Building the authorization url");
    Id4meIdentityAuthorityData data = sessionData.iauData;
    Map<String, dynamic> wellKnown = sessionData.iauData.wellKnown;
    Map<String, String> queryParameters = Map<String, String>();
    queryParameters["scope"] = claimsConfig.scopes;

    if (wellKnown.containsKey("claims_parameter_supported")) {
      bool claims_parameter_supported = wellKnown["claims_parameter_supported"];
      if (claims_parameter_supported) {
        Logger(TAG).info("Claims parameter are supported.");
        queryParameters["claims"] = claimsConfig.claimsParam.toString();
      } else {
        Logger(TAG).info("Claims parameter are not supported.");
        if (fallbackToScopes) {
          queryParameters["scope"] = claimsConfig.getScopesForClaims();
          Logger(TAG).info(
              "claims_parameter_supported == false AND fallbackToScops == true, add missing scopes for " +
                  data.iau +
                  ", set new scopeParam: " +
                  queryParameters["scope"]);
        } else {
          Logger(TAG).info("Claims parameter not supported for " +
              data.iau +
              ", fallback to scopes == false.");
        }
      }
    } else {
      queryParameters["claims"] = claimsConfig.claimsParam.toString();
      Logger(TAG).info(
          "claims_parameter_supported not found in .wellKnown data for " +
              data.iau +
              ", scopes not modified");
    }
    queryParameters["response_type"] = "code";
    queryParameters["client_id"] = sessionData.iauData.clientId;
    queryParameters["redirect_uri"] = sessionData.redirectUri;
    queryParameters["state"] = sessionData.state;
    queryParameters["nonce"] = sessionData.nonce;
    queryParameters["login_hint"] = sessionData.loginHint;
    String authUrl = data.wellKnown["authorization_endpoint"];
    String authorizeUri =
        Uri.parse(authUrl).replace(queryParameters: queryParameters).toString();

    Logger(TAG).info("Authorizing: authorize URI: {}", authorizeUri);

    return authorizeUri;
  }

  Future<void> authenticate(Id4meSessionData sessionData, String code) async {
    Map<String, dynamic> bearerToken = await getToken(sessionData, code);
    Logger(TAG).info("Authenticating with token: {}", bearerToken);
    if (bearerToken.containsKey("token_type")) {
      String type = bearerToken["token_type"];
      if (!StringUtils.equalsIgnoreCase(type, "bearer")) {
        // TODO Handle Bearer token not found in response
        // throw new TokenNotFoundException("Bearer token not found in response!");
      }
    }

    String identityHandle = null;
    if (bearerToken.containsKey("id_token")) {
      String idToken = bearerToken["id_token"];
      /*
      try {
        
        EncryptedJWT jwt = EncryptedJWT.parse(idToken);
        if (jwt.getIV() != null) {
          // id token seem to be encrypted
          if (keyPairHandler != null) {
            RSADecrypter decrypter =
                new RSADecrypter(keyPairHandler.getKeyPair().getPrivate());
            jwt.decrypt(decrypter);
            idToken = jwt.getPayload().toString();
          } else {
            throw new Exception(
                "id token seem to be encrypted but no KeyPair found!");
          }
        }
      } catch (ex) {
        // id token may not encrypted
        Logger(TAG).info(ex.toString());
      }
      */
      sessionData.idToken = idToken;
      if (identityHandle == null)
        identityHandle = identityHandleFromIdToken(sessionData, idToken);
    }

    if (bearerToken.containsKey("access_token")) {
      String accessToken = bearerToken["access_token"];
      sessionData.accessToken = accessToken;
      if (identityHandle == null)
        identityHandle =
            identityHandleFromAccessToken(sessionData, accessToken);
    }

    if (identityHandle != null) sessionData.identityHandle = identityHandle;

    sessionData.bearerToken = bearerToken;
    sessionData.userinfo = sessionData.accessTokenUserinfo;
    if (sessionData.userinfo == null)
      sessionData.userinfo = sessionData.idTokenUserinfo;

    if (getExpired(bearerToken) != null)
      sessionData.tokenExpires = getExpired(bearerToken);
    return;
  }

  Future<Map<String, dynamic>> userinfo(Id4meSessionData sessionData) async {
    Map<String, dynamic> userinfo = await getUserinfo(sessionData);

    /*
		if (userinfo.containsKey("claims")) {
			// workaround because of an iag error, move the claims from the claims array to
			// the json root element
			JSONObject json = new JSONObject();
			String[] names = JSONObject.getNames(userinfo);
			for (String n : names) {
				if (!n.equals("claims")) {
					json.put(n, userinfo.get(n));
				}

			}
			JSONObject claims = userinfo.getJSONObject("claims");
			names = JSONObject.getNames(claims);
			for (String n : names) {
				json.put(n, claims.get(n));
			}
			userinfo = json;
		}

		checkMandatoryClaims(userinfo);
    */
    sessionData.userinfo = userinfo;
    sessionData.state = "userinfo";
    return userinfo;
  }

  ///
  /// Builds the id4me session data, by fetching the DNS data and identity authority data.
  ///
  Future<Id4meSessionData> createSessionData(
      String id4me, bool autoRegisterClient) async {
    Logger(TAG).info("Fetching Id4meDnsData for login $id4me");
    Id4meDnsDataWithLoginHint dnsDataWithLoginHint =
        await Id4meResolver.getDataFromDns(id4me);

    Logger(TAG).info("Setup id4me session data");
    Id4meSessionData sessionData = new Id4meSessionData();
    sessionData.id4me = id4me;
    Id4meDnsData dnsData = dnsDataWithLoginHint.id4meDnsData;

    sessionData.loginHint = dnsDataWithLoginHint.loginHint;

    sessionData.iau = dnsData.iau;
    sessionData.iag = dnsData.iag;

    sessionData.redirectUri = this.redirectUri;
    sessionData.logoUri = this.logoUri;

    Id4meIdentityAuthorityData iauData = await fetchIauData(sessionData);
    sessionData.iauData = iauData;
    if (autoRegisterClient) {
      await doDynamicClientRegistration(sessionData);
    }
    if (logSessionData) {
      printSessionData(sessionData);
    }
    return sessionData;
  }

  ///
  /// Fetches the openid configuration for the identitity authority
  ///
  Future<Id4meIdentityAuthorityData> fetchIauData(
      Id4meSessionData sData) async {
    String iau = sData.iau;
    String wellKnownUri =
        "https://" + iau + "/.well-known/openid-configuration";
    Logger(TAG).info("Fetch openid configuration for $iau at $wellKnownUri");
    Id4meIdentityAuthorityData iauData = new Id4meIdentityAuthorityData();
    Map<String, dynamic> wellKnownData = await HttpUtils.get(wellKnownUri);
    iauData.wellKnown = wellKnownData;
    return iauData;
  }

  ///
  /// Fetch the registration data for the identitity authority
  ///
  Future<Map<String, dynamic>> getRegistrationData(
      Id4meSessionData sessionData) async {
    Id4meIdentityAuthorityData data = sessionData.iauData;
    String url = data.wellKnown["registration_endpoint"];

    List<String> encoded = [];
    for (String u in redirectUris) {
      String e = Uri.encodeFull(u);
      encoded.add(e);
    }

    Map<String, dynamic> bodyAsMap = new Map<String, dynamic>();
    bodyAsMap.putIfAbsent("redirect_uris", () => encoded);
    bodyAsMap.putIfAbsent("client_name", () => clientName);
    if (logoUri != null && logoUri.trim().isNotEmpty) {
      bodyAsMap.putIfAbsent("logo_uri", () => logoUri); // TODO URL Encode
    }

    bodyAsMap.putIfAbsent("application_type", () => "web"); // TODO change later

    // TODO KEY PAIR HANDLER

    String body = json.encode(bodyAsMap);
    Map<String, String> headers = Map<String, String>();
    headers.putIfAbsent("Content-Type", () => "application/json");

    return await HttpUtils.post(url, body, headers: headers);
  }

  Future<void> doDynamicClientRegistration(Id4meSessionData sessionData) async {
    String iau = sessionData.iau;
    Logger(TAG).info("Trying dynamic client registration for IAU: " + iau);
    Id4meIdentityAuthorityData data = sessionData.iauData;
    if (data == null) {
      throw new Exception(
          "No iau data found in session for dynamic client registration!");
    }

    if (data.wellKnown == null) {
      throw new Exception(
          "well-known data not found in session for dynamic client registration!");
    }

    Map<String, dynamic> registrationData =
        await getRegistrationData(sessionData);
    //data = storage.saveRegistrationData(registrationDataPath, iau, registrationData);
    // restore the .well-known data
    // data.setWellKnown(well_known);
    data.clientId = registrationData["client_id"];
    data.clientSecret = registrationData["client_secret"];
    data.registrationData = registrationData;
    sessionData.iauData = data;
    return;
  }

  Future<Map<String, dynamic>> getToken(
      Id4meSessionData logonData, String code) async {
    Id4meIdentityAuthorityData data = logonData.iauData;
    String url = data.wellKnown["token_endpoint"];
    Map<String, String> parameters = Map<String, String>();
    parameters["grant_type"] = "authorization_code";
    parameters["code"] = code;
    parameters["redirect_uri"] = logonData.redirectUri;
    parameters["nonce"] = logonData.nonce;

    String user = logonData.iauData.clientId;
    String password = logonData.iauData.clientSecret;
    String auth = base64.encode(utf8.encode("$user:$password"));
    auth = "Basic $auth";

    Map<String, String> headers = Map<String, String>();
    headers["Content-Type"] = "application/x-www-form-urlencoded";
    headers["Authorization"] = auth;

    return await HttpUtils.post(url, "",
        queryParameters: parameters, headers: headers);
  }

  int getExpired(Map<String, dynamic> token) {
    if (token.containsKey("expires_in")) {
      int exp = token["expires_in"];
      int now = new DateTime.now().millisecondsSinceEpoch;
      int expIn = now + exp * 1000;
      Logger(TAG).info("Authenticate: Set token to expire in $exp sec");
      return expIn;
    }
    return null;
  }

  String identityHandleFromIdToken(
      Id4meSessionData sessionData, String idToken) {
    String identityHandle = sessionData.identityHandle;
    List<String> idFields = idToken.split("\\.");
    switch (idFields.length) {
      case 1:
        Logger(TAG).info("IdToken contains only a header");
        break;
      case 2:
        Logger(TAG).info("IdToken contains header and payload");
        break;
      case 3:
        Logger(TAG).info("IdToken contains header, payload and signature");
        // TODO IMPLEMENT
        /* 
			SignedJWT signedToken = (SignedJWT) JWTParser.parse(idToken);
			Map<String,dynamic> jwtsData = fetchJwtsData(sessionData);
			validateSignedToken(jwtsData, signedToken);
			validateIdTokenPayload(sessionData, signedToken);
			Map<String,dynamic> userinfo = new JSONObject(signedToken.getPayload().toString());
			sessionData.idTokenUserinfo = userinfo;
			if (userinfo.containsKey("iss") && userinfo.containsKey("sub")) {
				String identity = userinfo["iss"] + "#" + userinfo["sub"];
				if (identityHandle != null && identity != identityHandle) {
					throw new Exception("claims sub + iss from access_token and id_token are different!");
				} else {
					identityHandle = identity;
				}
			}
      */
        break;
      default:
    }
    return identityHandle;
  }

  String identityHandleFromAccessToken(
      Id4meSessionData sessionData, String accessToken) {
    Logger(TAG).info("Try to get identity handle from access_token");
    String identityHandle = null;
    List<String> aFields = accessToken.split("\\.");

    switch (aFields.length) {
      case 1:
        Logger(TAG).info("AccessToken contains only a header");
        break;
      case 2:
        Logger(TAG).info("AccessToken contains header and payload");
        break;
      case 3:
        Logger(TAG).info("AccessToken contains header, payload and signature");
        // TODO Implement
        /*
			SignedJWT signedToken = (SignedJWT) JWTParser.parse(access_token);
			JSONObject jwtsData = fetchJwtsData(sessionData);
			validateSignedToken(jwtsData, signedToken);
			Map<String,dynamic> userinfo = new JSONObject(signedToken.getPayload().toString());
			sessionData.accessTokenUserinfo = userinfo;
			if (userinfo.containsKey("iss") && userinfo.containsKey("sub")) {
				identityHandle = userinfo["iss"] + "#" + userinfo["sub"];
			}
      */
        break;
      default:
    }
    return identityHandle;
  }

  Future<Map<String, dynamic>> getUserinfo(Id4meSessionData sessionData) async {
    // String name = "_443._tcp." + sessionData.iag + ".";
    // List<RRecord> records = await DnsUtils.lookupRecord(name, RRecordType.TLSA);
    // TODO Check WHY and Handle lookup error

    String url = sessionData.iauData.wellKnown["userinfo_endpoint"];
    String authHeader = "Bearer " + sessionData.accessToken;

    Logger(TAG).info("Fetch userinfo: URL:         {}", url);
    Logger(TAG).info("Fetch userinfo: authHeader:  {}", authHeader);

    Map<String, String> headers = new Map<String, String>();
    headers["Authorization"] = authHeader;

    Map<String, dynamic> response = await HttpUtils.get(url, headers: headers);

    if (response.containsKey("_claim_sources") &&
        response.containsKey("_claim_names")) {
      // distributed claims
      //userinfo = getDistributedClaims(userinfo);
    }

    if (response.containsKey("error")) {
      if (response.containsKey("error_description"))
        throw new Exception(response["error_description"]);
      else
        throw new Exception("Unknown error while fetching user info");
    }
    return response;
  }

  ///
  /// Logs the given session data
  ///
  void printSessionData(Id4meSessionData data) {
    Logger(TAG).info("id4me = " + data.id4me);
    Logger(TAG).info("loginHint = " + data.loginHint);
    Logger(TAG).info("redirectUri = " + data.redirectUri);
    Logger(TAG).info("logoUri = " + data.logoUri);
    Logger(TAG).info("state = " + data.state);
    Logger(TAG).info("nonce = " + data.nonce);
    Logger(TAG).info("scope = " + data.scope);
  }
}
