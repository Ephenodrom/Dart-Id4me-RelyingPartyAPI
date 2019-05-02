part of id4me_api;

class Id4meResolver {
  static String TAG = "Id4meResolver";

  static Future<Id4meDnsDataWithLoginHint> getDataFromDns(String id4me,
      {dnssec = false}) async {
    if (!Id4meValidator.isValidUserid(id4me)) {
      throw new Exception("ID4me identifier has wrong format: " + id4me);
    }
    String loginHint;
    int atPos = id4me.indexOf('@');
    if (atPos > 0) {
      String localPart = id4me.substring(0, atPos);
      String domain = id4me.substring(atPos + 1, id4me.length);
      //id4me = sha256(localPart) + "._openid." + domain;
      loginHint = localPart + "." + domain;
    } else {
      loginHint = id4me;
      id4me = "_openid." + id4me;
    }

    String domain = id4me.endsWith(".") ? id4me : id4me + ".";
    List<RRecord> records =
        await DnsUtils.lookupRecord(domain, RRecordType.TXT, dnssec: dnssec);

    Id4meDnsData dnsData = getId4meDnsDataFromRRecords(records);

    return Id4meDnsDataWithLoginHint(dnsData, loginHint);
  }

  static Id4meDnsData getId4meDnsDataFromRRecords(List<RRecord> records) {
    String v = null;
    String iau = null;
    String iag = null;

    records.forEach((r) {
      if (r.name.startsWith("_openid")) {
        String data = r.data.replaceAll('"', "");
        List<String> values = data.split(";");
        values.forEach((value) {
          List<String> e = value.trim().split("=");
          if (e.length == 2) {
            if ("v" == e[0]) {
              if (v != null) {
                Logger(TAG)
                    .info("More than one v field found in TXT RR: {}", r.data);
                throw new Exception(
                    "More than one v field found in TXT RR: " + r.data);
              } else {
                v = e[1].trim();
              }
            }
            if ("iss" == e[0]) {
              if (iau != null) {
                Logger(TAG).info(
                    "More than one iss field found in TXT RR: {}", r.data);
                throw new Exception(
                    "More than one iss field found in TXT RR: " + r.data);
              } else {
                iau = e[1].trim();
                // TODO iau = IDN.toASCII(iau);
              }
            }
            if ("clp" == e[0]) {
              if (iag != null) {
                Logger(TAG).info(
                    "More than one clp field found in TXT RR: {}", r.data);
                throw new Exception(
                    "More than one clp field found in TXT RR: " + r.data);
              } else {
                iag = e[1].trim();
                // TODO iag = IDN.toASCII(iag);
              }
            }

            if ("iau" == e[0]) {
              if (iau != null) {
                Logger(TAG).info(
                    "More than one iss field found in TXT RR: {}", r.data);
                throw new Exception(
                    "More than one iss field found in TXT RR: " + r.data);
              } else {
                iau = e[1].trim();
                // TODO iau = IDN.toASCII(iau);
              }
            }
            if ("iag" == e[0]) {
              if (iag != null) {
                Logger(TAG).info(
                    "More than one clp field found in TXT RR: {}", r.data);
                throw new Exception(
                    "More than one clp field found in TXT RR: " + r.data);
              } else {
                iag = e[1].trim();
                // TODO iag = IDN.toASCII(iag);
              }
            }
          }
        });
      }
    });
    if (v != null && iag != null && iau != null) {
      return Id4meDnsData(v, iau, iag);
    } else {
      return null;
    }
  }
}
