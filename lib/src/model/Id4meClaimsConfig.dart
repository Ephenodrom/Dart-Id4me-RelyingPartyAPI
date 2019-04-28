part of id4me_api;

class Id4meClaimsConfig {
  List<Entry> entries;
  Map<String, dynamic> claimsParam;
  Set<String> essentialClaims;
  List<String> profile = [
    "name",
    "family_name",
    "given_name",
    "middle_name",
    "nickname",
    "preferred_username",
    "profile",
    "picture",
    "website",
    "gender",
    "birthdate",
    "zoneinfo",
    "locale",
    "updated_at"
  ];
  List<String> email = ["email", "email_verified"];
  List<String> address = ["address"];
  List<String> phone = ["phone_number", "phone_number_verified"];
  String scopes;

  Id4meClaimsConfig(
      {this.entries,
      this.claimsParam,
      this.essentialClaims,
      this.profile,
      this.email,
      this.address,
      this.phone,
      this.scopes = "openid"});

  ///
  /// Add scopes which contain requested claims. Is used when claims_parameter_supported is false AND fallbackToScopes 
  /// is true at Id4meLogon.authorize(Id4meSessionData sessionData)
  ///
  String getScopesForClaims() {
    Map<String, dynamic> userinfo = claimsParam["userinfo"];
    String s = scopes;
    for (String c in userinfo.keys) {
      if (isInList(c, profile)) {
        if (s.indexOf("profile") < 0) s += " profile";
      }
      if (isInList(c, email)) {
        if (s.indexOf("email") < 0) s += " email";
      }
      if (isInList(c, address)) {
        if (s.indexOf("address") < 0) s += " address";
      }
      if (isInList(c, phone)) {
        if (s.indexOf("phone") < 0) s += " phone";
      }
    }

    return s.trim();
  }

  bool isInList(String v, List<String> list) {
    for (String e in list) {
      if (StringUtils.equalsIgnoreCase(e, v)) {
        return true;
      }
    }
    return false;
  }

  ///
  /// Adds a scope permanently to the scopes for this {@link Id4meClaimsConfig}
  ///
  void addScope(String scope) {
    if (scopes.indexOf(scope) < 0) scopes += " " + scope;
  }
  /*


      	/**
	 * Builds the ID4me claims configuration based on the specified parameters.
	 * 
	 * @param parameters
	 *            the claims parameters
	 */
	Id4meClaimsConfig(Id4meClaimsParameters parameters) {
		this.entries = Collections.unmodifiableList(new ArrayList<>(parameters.getEntries()));
		this.claimsParam = buildClaimsParam();
		log.info("Configured claims param:     {}", claimsParam);

		this.essentialClaims = buildEssentialClaims();
		log.info("Configured essential claims: {}", essentialClaims);
	}

	private String buildClaimsParam() {
		JSONObject userinfo = new JSONObject();
		for (Entry entry : entries) {
			JSONObject p = null;

			if (entry.isEssential()) {
				p = new JSONObject();
				p.put("essential", true);
			}

			String reason = entry.getReason();
			if (reason != null && !reason.equals("")) {
				p = p == null ? new JSONObject() : p;
				p.put("reason", reason);
			}

			if (p != null)
				userinfo.put(entry.getName(), p);
			else
				userinfo.put(entry.getName(), JSONObject.NULL);
		}

		return "{\"userinfo\":" + userinfo.toString() + "}";
	}

	private Set<String> buildEssentialClaims() {
		Set<String> claims = new HashSet<>();
		for (Entry entry : entries) {
			if (entry.isEssential()) {
				claims.add(entry.getName());
			}
		}
		return Collections.unmodifiableSet(claims);
	}

	/**
	 * Returns a set of essential claim names.
	 * 
	 * @return the set of essential claim names
	 */
	Set<String> getEssentialClaims() {
		return essentialClaims;
	}

	/**
	 * Checks if the specified claim is essential.
	 * 
	 * @param claimName
	 *            the claim name
	 * 
	 * @return whether the specified claim is essential
	 */
	boolean isEssential(String claimName) {
		return essentialClaims.contains(claimName);
	}
  */
}
