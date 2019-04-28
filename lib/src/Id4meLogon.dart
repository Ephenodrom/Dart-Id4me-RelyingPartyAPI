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

  Id4meLogon(
      {Map<String, dynamic> properties, Map<String, dynamic> claimsParameters, List<String> scopes}) {
    if (properties != null) {
      _readProperties(properties);
    }
    claimsConfig = new Id4meClaimsConfig(claimsParam:claimsParameters);
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

    this.resolver = new Id4meResolver(dnsResolver, dnssecRootKey,
        properties[Id4meConstants.KEY_DNSSEC_REQUIRED]);

    if (properties.containsKey(Id4meConstants.KEY_PRIVATE_KEY) &&
        properties.containsKey(Id4meConstants.KEY_PUBLIC_KEY)) {
      keyPairHandler = new Id4meKeyPairHandler(
          properties[Id4meConstants.KEY_PRIVATE_KEY],
          properties[Id4meConstants.KEY_PUBLIC_KEY]);
    }
  }

  String authorize(Id4meSessionData sessionData) {
    Id4meIdentityAuthorityData data = sessionData.iauData;
		Map<String,dynamic> wellKnown = sessionData.iauData.wellKnown;
		String claimsParam = "";		
		String scopeParam = "&scope=" + claimsConfig.scopes;
		
		if (wellKnown.containsKey("claims_parameter_supported")) {
			bool claims_parameter_supported = wellKnown["claims_parameter_supported"];
			if (claims_parameter_supported) {
				Logger(TAG).info("Claims parameter are supported.");
				claimsParam = "&claims=" + claimsConfig.claimsParam.toString();
			} else {
				Logger(TAG).info("Claims parameter are not supported.");
				if (fallbackToScopes) {
					scopeParam = "&scope=" + claimsConfig.getScopesForClaims();
					Logger(TAG).info("claims_parameter_supported == false AND fallbackToScops == true, add missing scopes for " + data.iau);
					Logger(TAG).info(data.iau + ", set new scopeParam: " + scopeParam);
				} else {
					Logger(TAG).info("Claims parameter not supported for " + data.iau + ", fallback to scopes == false.");
				}
			}
		} else {
			claimsParam = "&claims=" + claimsConfig.claimsParam.toString();
			Logger(TAG).info("claims_parameter_supported not found in .wellKnown data for " + data.iau + ", scopes not modified");
		}

		String authorizeUri = data.wellKnown["authorization_endpoint"] + "?" + "response_type=code"
				+ claimsParam + scopeParam + "&client_id=" + sessionData.iauData.clientId + "&redirect_uri="
				+ sessionData.redirectUri + "&state=" + sessionData.state + "&nonce=" + sessionData.nonce
				+ "&login_hint=" + sessionData.loginHint;

		Logger(TAG).info("Authorizing: authorize URI: {}", authorizeUri);

		return authorizeUri;

  }

  void authenticate(Id4meSessionData sessionData, String code) {}

  void userinfo(Id4meSessionData sessionData) {}

  Future<Id4meSessionData> createSessionData(
      String id4me, bool autoRegisterClient) async {
    Id4meSessionData sessionData = new Id4meSessionData();
    sessionData.id4me = id4me;
    Id4meDnsDataWithLoginHint dnsDataWithLoginHint =
        await resolver.getDataFromDns(id4me);

    Id4meDnsData dnsData = dnsDataWithLoginHint.id4meDnsData;

    sessionData.loginHint = dnsDataWithLoginHint.loginHint;

    sessionData.iau = dnsData.iau;
    sessionData.iag = dnsData.iag;

    sessionData.redirectUri = this.redirectUri;
    sessionData.logoUri = this.logoUri;

    Logger(TAG).info("Creating session data using login hint: " +
        dnsDataWithLoginHint.loginHint);
    Logger(TAG)
        .info("Creating session data using redirect URI: " + redirectUri);
    Logger(TAG).info("Creating session data using logo URI: " + logoUri);

    Id4meIdentityAuthorityData iauData = await getIauData(sessionData, autoRegisterClient);
    sessionData.iauData = iauData;
    // TODO doDynamicClientRegistration(sessionData);
    return sessionData;
  }

  ///
  /// Gets the .well-known/openid-configuration for the identitity authority
  ///
  Future<Id4meIdentityAuthorityData> getIauData(Id4meSessionData sessionData, bool autoRegisterClient) async {
    String iau = sessionData.iau;
    Logger(TAG).info("Retrieving identity authority: " + iau);

    Id4meIdentityAuthorityData data = new Id4meIdentityAuthorityData();

    String wellKnownUri =
        "https://" + iau + "/.well-known/openid-configuration";
    Map<String, dynamic> wellKnownData = await HttpUtils.get(wellKnownUri);
    data.wellKnown = wellKnownData;
    Logger(TAG).info(wellKnownData.toString());
    return data;
  }
}
