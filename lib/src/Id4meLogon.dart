part of id4me_api;

class Id4meLogon {
  String TAG = 'Id4meLogon';

  Id4meResolver resolver;
  String clientName;
  String redirectUri;
  List<String> redirectUris;
  String logoUri;
  String registrationDataPath;
  Id4meClaimsConfig claimsConfig;
  Id4meKeyPairHandler keyPairHandler;
  bool fallbackToScopes;
  bool logSessionData;
  bool dnsSecRequired = false;

  Id4meLogon(
      {Map<String, dynamic> properties,
      Map<String, dynamic> claimsParameters,
      List<String> scopes,
      this.logSessionData = false}) {
    if (properties != null) {
      _readProperties(properties);
    }
    if (!Id4meValidator.isValidClaimsParameters(claimsParameters)) {
      throw Exception('Invalid claims parameters!');
    }
    claimsConfig = Id4meClaimsConfig(claimsParam: claimsParameters);
    if (scopes != null) {
      for (var scope in scopes) {
        claimsConfig.addScope(scope);
      }
    }
  }

  void _readProperties(Map<String, dynamic> properties) {
    if (properties.containsKey(Id4meConstants.KEY_CLIENT_NAME)) {
      clientName = properties[Id4meConstants.KEY_CLIENT_NAME];
    } else {
      throw Exception('Id4meProperties.clientName not set');
    }

    if (properties.containsKey(Id4meConstants.KEY_REDIRECT_URI)) {
      redirectUri = properties[Id4meConstants.KEY_REDIRECT_URI];
    } else {
      throw Exception('Id4meProperties.redirectURI not set');
    }

    if (properties.containsKey(Id4meConstants.KEY_REDIRECT_URIS)) {
      redirectUris = properties[Id4meConstants.KEY_REDIRECT_URIS];
    } else {
      redirectUris = [redirectUri];
    }

    if (properties.containsKey(Id4meConstants.KEY_LOGO_URI)) {
      logoUri = properties[Id4meConstants.KEY_LOGO_URI];
    }

    if (properties.containsKey(Id4meConstants.KEY_REGISTRATION_DATA_PATH)) {
      registrationDataPath =
          properties[Id4meConstants.KEY_REGISTRATION_DATA_PATH];
    } else {
      registrationDataPath = './';
    }

    dnsSecRequired = properties[Id4meConstants.KEY_DNSSEC_REQUIRED];

    if (properties.containsKey(Id4meConstants.KEY_PRIVATE_KEY) &&
        properties.containsKey(Id4meConstants.KEY_PUBLIC_KEY)) {
      keyPairHandler = Id4meKeyPairHandler(
          properties[Id4meConstants.KEY_PRIVATE_KEY],
          properties[Id4meConstants.KEY_PUBLIC_KEY]);
    }
  }

  ///
  /// Builds the authorization url.
  ///
  String buildAuthorizationUrl(Id4meSessionData sessionData) {
    Logger(TAG).info('Building the authorization url');
    var data = sessionData.iauData;
    var wellKnown = sessionData.iauData.wellKnown;
    var queryParameters = <String, String>{};
    queryParameters['response_type'] = 'code';

    if (wellKnown.containsKey('claims_parameter_supported')) {
      bool claims_parameter_supported = wellKnown['claims_parameter_supported'];
      if (claims_parameter_supported) {
        Logger(TAG).info('Claims parameter are supported.');
        queryParameters['claims'] = json.encode(claimsConfig.claimsParam);
      } else {
        Logger(TAG).info('Claims parameter are not supported.');
        if (fallbackToScopes) {
          queryParameters['scope'] = claimsConfig.getScopesForClaims();
          Logger(TAG).info(
              'claims_parameter_supported == false AND fallbackToScopes == true, add missing scopes for ' +
                  data.iau +
                  ', set new scopeParam: ' +
                  queryParameters['scope']);
        } else {
          Logger(TAG).info('Claims parameter not supported for ' +
              data.iau +
              ', fallback to scopes == false.');
        }
      }
    } else {
      queryParameters['claims'] = claimsConfig.claimsParam.toString();
      Logger(TAG).info(
          'claims_parameter_supported not found in .wellKnown data for ' +
              data.iau +
              ', scopes not modified');
    }
    queryParameters['scope'] = claimsConfig.scopes;
    queryParameters['client_id'] = sessionData.iauData.clientId;
    queryParameters['redirect_uri'] = sessionData.redirectUri;
    queryParameters['state'] = sessionData.state;
    queryParameters['nonce'] = sessionData.nonce;
    queryParameters['login_hint'] = sessionData.loginHint;
    String authUrl = data.wellKnown['authorization_endpoint'];
    var authorizeUri =
        Uri.parse(authUrl).replace(queryParameters: queryParameters).toString();

    Logger(TAG).info('Authorizing: authorize URI: {}', authorizeUri);

    return authorizeUri;
  }

  ///
  /// Foo
  ///
  /// Throws an [BearerTokenFetchException] if the bearer token could not be fetched from the Identity Authority.
  /// Throws an [BearerTokenNotFoundException] if there is no bearer token in the response from the Identity Authority.
  ///
  Future<void> authenticate(Id4meSessionData sessionData, String code) async {
    var bearerToken = await getToken(sessionData, code);
    if (bearerToken == null) {
      throw BearerTokenFetchException();
    }
    Logger(TAG).info('Authenticating with token: {}', bearerToken);
    if (bearerToken.containsKey('token_type')) {
      String type = bearerToken['token_type'];
      if (!StringUtils.equalsIgnoreCase(type, 'bearer')) {
        throw BearerTokenNotFoundException();
      }
    }

    String identityHandle;
    if (bearerToken.containsKey('id_token')) {
      String idToken = bearerToken['id_token'];

      // TODO HANDLE JWT ENCRYPTED

      sessionData.idToken = idToken;
      identityHandle ??= identityHandleFromIdToken(sessionData, idToken);
    }

    if (bearerToken.containsKey('access_token')) {
      String accessToken = bearerToken['access_token'];
      sessionData.accessToken = accessToken;
      identityHandle ??=
          identityHandleFromAccessToken(sessionData, accessToken);
    }

    if (identityHandle != null) {
      sessionData.identityHandle = identityHandle;
    }

    sessionData.bearerToken = bearerToken;
    sessionData.userinfo = sessionData.accessTokenUserinfo;
    sessionData.userinfo ??= sessionData.idTokenUserinfo;

    if (getExpired(bearerToken) != null) {
      sessionData.tokenExpires = getExpired(bearerToken);
    }
    return;
  }

  ///
  ///
  /// Throws [MandatoryClaimsException] if one of the mandatory claims is missing in the userinfo.
  ///
  Future<Map<String, dynamic>> fetchUserinfo(
      Id4meSessionData sessionData) async {
    var userInfo = await getUserinfo(sessionData);
    if (userInfo == null) {
      throw UserInfoFetchException();
    }

    checkMandatoryClaims(userInfo);

    sessionData.userinfo = userInfo;
    sessionData.state = 'userinfo';
    return userInfo;
  }

  ///
  /// Checks if the given [userInfo] contains every mandatory claim.
  ///
  /// Throws [MandatoryClaimsException] if one of the mandatory claims is missing in the userinfo.
  ///
  void checkMandatoryClaims(Map<String, dynamic> userInfo) {
    Logger(TAG).info('Check if all mandatory claims exist in the userinfo');
    for (var claimName in claimsConfig.essentialClaims) {
      if (!userInfo.containsKey(claimName)) {
        Logger(TAG).info(
            'Mandatory claim \'$claimName\' not found in userinfo: $userInfo');
        throw MandatoryClaimsException(
            message: 'Mandatory claim \'$claimName\' not found!');
      }
    }
  }

  ///
  /// Builds the id4me session data, by fetching the DNS data and identity authority data.
  ///
  /// Throws an [DnsResolveException] if the dns lookup for the given [id4me] is not possible.
  /// Throws an [IdentityAuthorityDataFetchException] if the Identity Authority data could not be fetched.
  ///
  Future<Id4meSessionData> createSessionData(
      String id4me, bool autoRegisterClient) async {
    Logger(TAG).info('Fetching Id4meDnsData for login $id4me');
    var dnsDataWithLoginHint =
        await Id4meResolver.getDataFromDns(id4me, dnssec: dnsSecRequired);
    if (dnsDataWithLoginHint == null) {
      throw DnsResolveException();
    }
    Logger(TAG).info('Setup id4me session data');
    var sessionData = Id4meSessionData();
    sessionData.id4me = id4me;
    var dnsData = dnsDataWithLoginHint.id4meDnsData;

    sessionData.loginHint = dnsDataWithLoginHint.loginHint;

    sessionData.iau = dnsData.iau;
    sessionData.iag = dnsData.iag;

    sessionData.redirectUri = redirectUri;
    sessionData.logoUri = logoUri;

    var iauData = await fetchIauData(sessionData);
    if (dnsDataWithLoginHint == null) {
      throw IdentityAuthorityDataFetchException();
    }
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
    var iau = sData.iau;
    var wellKnownUri = 'https://' + iau + '/.well-known/openid-configuration';
    Logger(TAG).info('Fetch openid configuration for $iau at $wellKnownUri');
    var iauData = Id4meIdentityAuthorityData();
    Map<String, dynamic> wellKnownData;
    try {
      wellKnownData = await HttpUtils.getForJson(wellKnownUri);
    } catch (e) {
      Logger(TAG)
          .info('Could not fetch Identity Authority data. ' + e.toString());
      return null;
    }
    iauData.wellKnown = wellKnownData;
    return iauData;
  }

  ///
  /// Fetch the registration data for the identitity authority
  ///
  Future<Map<String, dynamic>> getRegistrationData(
      Id4meSessionData sessionData) async {
    var data = sessionData.iauData;
    String url = data.wellKnown['registration_endpoint'];

    var encoded = [];
    for (var u in redirectUris) {
      var e = Uri.encodeFull(u);
      encoded.add(e);
    }

    var bodyAsMap = <String, dynamic>{};
    bodyAsMap.putIfAbsent('redirect_uris', () => encoded);
    bodyAsMap.putIfAbsent('client_name', () => clientName);
    if (logoUri != null && logoUri.trim().isNotEmpty) {
      bodyAsMap.putIfAbsent('logo_uri', () => logoUri); // TODO URL Encode
    }

    bodyAsMap.putIfAbsent('application_type', () => 'web'); // TODO change later

    // TODO KEY PAIR HANDLER

    var body = json.encode(bodyAsMap);
    var headers = <String, String>{};
    headers.putIfAbsent('Content-Type', () => 'application/json');

    return await HttpUtils.postForJson(url, body, headers: headers);
  }

  Future<void> doDynamicClientRegistration(Id4meSessionData sessionData) async {
    var iau = sessionData.iau;
    Logger(TAG).info('Trying dynamic client registration for IAU: ' + iau);
    var data = sessionData.iauData;
    if (data == null) {
      throw Exception(
          'No iau data found in session for dynamic client registration!');
    }

    if (data.wellKnown == null) {
      throw Exception(
          'well-known data not found in session for dynamic client registration!');
    }

    var registrationData = await getRegistrationData(sessionData);
    //data = storage.saveRegistrationData(registrationDataPath, iau, registrationData);
    // restore the .well-known data
    // data.setWellKnown(well_known);
    data.clientId = registrationData['client_id'];
    data.clientSecret = registrationData['client_secret'];
    data.registrationData = registrationData;
    sessionData.iauData = data;
    return;
  }

  ///
  /// Fetch the bearer token from the Identity Authority
  ///
  Future<Map<String, dynamic>> getToken(
      Id4meSessionData logonData, String code) async {
    var data = logonData.iauData;
    String url = data.wellKnown['token_endpoint'];
    var parameters = <String, String>{};
    parameters['grant_type'] = 'authorization_code';
    parameters['code'] = code;
    parameters['redirect_uri'] = logonData.redirectUri;
    parameters['nonce'] = logonData.nonce;

    var user = logonData.iauData.clientId;
    var password = logonData.iauData.clientSecret;
    var auth = base64.encode(utf8.encode('$user:$password'));
    auth = 'Basic $auth';

    var headers = <String, String>{};
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    headers['Authorization'] = auth;

    try {
      return await HttpUtils.postForJson(url, '',
          queryParameters: parameters, headers: headers);
    } catch (e) {
      Logger(TAG).info(
          'Could not fetch bearer token from Identity Authority. ' +
              e.toString());
      return null;
    }
  }

  int getExpired(Map<String, dynamic> token) {
    if (token.containsKey('expires_in')) {
      int exp = token['expires_in'];
      var now = DateTime.now().millisecondsSinceEpoch;
      var expIn = now + exp * 1000;
      Logger(TAG).info('Authenticate: Set token to expire in $exp sec');
      return expIn;
    }
    return null;
  }

  String identityHandleFromIdToken(
      Id4meSessionData sessionData, String idToken) {
    var identityHandle = sessionData.identityHandle;
    var idFields = idToken.split('.');
    switch (idFields.length) {
      case 1:
        Logger(TAG).info('IdToken contains only a header');
        break;
      case 2:
        Logger(TAG).info('IdToken contains header and payload');
        break;
      case 3:
        Logger(TAG).info('IdToken contains header, payload and signature');
        var jwt = JsonWebToken.unverified(idToken);
        var userinfo = jwt.claims.toJson();
        sessionData.idTokenUserinfo = userinfo;
        if (userinfo.containsKey('iss') && userinfo.containsKey('sub')) {
          String identity = userinfo['iss'] + '#' + userinfo['sub'];
          if (identityHandle != null && identity != identityHandle) {
            throw Exception(
                'claims sub + iss from access_token and id_token are different!');
          } else {
            identityHandle = identity;
          }
        }
        break;
      default:
    }
    return identityHandle;
  }

  String identityHandleFromAccessToken(
      Id4meSessionData sessionData, String accessToken) {
    Logger(TAG).info('Try to get identity handle from access_token');
    String identityHandle;
    var aFields = accessToken.split('.');

    switch (aFields.length) {
      case 1:
        Logger(TAG).info('AccessToken contains only a header');
        break;
      case 2:
        Logger(TAG).info('AccessToken contains header and payload');
        break;
      case 3:
        Logger(TAG).info('AccessToken contains header, payload and signature');
        var jwt = JsonWebToken.unverified(accessToken);
        var userinfo = jwt.claims.toJson();
        sessionData.accessTokenUserinfo = userinfo;
        if (userinfo.containsKey('iss') && userinfo.containsKey('sub')) {
          identityHandle = userinfo['iss'] + '#' + userinfo['sub'];
        }
        break;
      default:
    }
    return identityHandle;
  }

  ///
  /// Fetches the user info from the Idendity Agent. Returns null if something unexpected happens.
  ///
  Future<Map<String, dynamic>> getUserinfo(Id4meSessionData sessionData) async {
    // String name = '_443._tcp.' + sessionData.iag + '.';
    // List<RRecord> records = await DnsUtils.lookupRecord(name, RRecordType.TLSA);
    // TODO Check WHY and Handle lookup error

    String url = sessionData.iauData.wellKnown['userinfo_endpoint'];
    var authHeader = 'Bearer ' + sessionData.accessToken;

    Logger(TAG).info('Fetch userinfo: URL:         {}', url);
    Logger(TAG).info('Fetch userinfo: authHeader:  {}', authHeader);

    var headers = <String, String>{};
    headers['Authorization'] = authHeader;

    Map<String, dynamic> response;
    try {
      response = await HttpUtils.getForJson(url, headers: headers);
    } catch (e) {
      Logger(TAG).info(
          'Could not fetch user data from Identity Agent. ' + e.toString());
      return null;
    }

    if (response.containsKey('_claim_sources') &&
        response.containsKey('_claim_names')) {
      response = await getDistributedClaims(response);
    }

    if (response.containsKey('error')) {
      if (response.containsKey('error_description')) {
        Logger(TAG).info(response['error_description']);
        return null;
      } else {
        Logger(TAG).info('Unknown error while fetching user info');
        return null;
      }
    }
    return response;
  }

  Future<Map<String, dynamic>> getDistributedClaims(
      Map<String, dynamic> userInfo) async {
    var currentUserInfo = <String, dynamic>{};
    var claimSources = userInfo['_claim_sources'];
    var sources = claimSources.keys.toList();
    for (String src in sources) {
      Map<String, dynamic> ep = claimSources[src];
      String endpoint = ep['endpoint'];
      String accessToken = ep['access_token'];

      var authHeader = 'Bearer ' + accessToken;
      var headers = <String, String>{};
      headers['Authorization'] = authHeader;
      var response = await HttpUtils.getForString(endpoint, headers: headers);
      var responseFields = response.split('.');
      var normalized = base64.normalize(responseFields.elementAt(1));
      Iterable<int> inputAsUint8List = base64.decode(normalized);

      var s = String.fromCharCodes(inputAsUint8List);
      Map<String, dynamic> payload = json.decode(s);
      var names = payload.keys.toList();
      for (var n in names) {
        currentUserInfo[n] = payload[n];
      }
    }
    return currentUserInfo;
  }

  ///
  /// Logs the given session data
  ///
  void printSessionData(Id4meSessionData data) {
    Logger(TAG).info('id4me = ' + data.id4me);
    Logger(TAG).info('loginHint = ' + data.loginHint);
    Logger(TAG).info('redirectUri = ' + data.redirectUri);
    Logger(TAG).info('logoUri = ' + data.logoUri);
    Logger(TAG).info('state = ' + data.state);
    Logger(TAG).info('nonce = ' + data.nonce);
    Logger(TAG).info('scope = ' + data.scope);
  }
}
