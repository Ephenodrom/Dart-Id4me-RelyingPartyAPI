part of id4me_api;

///
/// Class for fetching and processing data from the _openid TXT record
///
class Id4meResolver {
  static String TAG = 'Id4meResolver';

  ///
  /// Fetches the data from the _openid TXT record for the given [id4me] domain.
  /// Trys to build up an instance of Id4meDnsDataWithLoginHint and returns it.
  ///
  /// Throws an [Id4meIdentifierFormatException] if the identifier has the wrong format.
  /// Throws an [DnsDataNotParseableException] if [Id4meDnsData] could not be parsed from dns record value.
  ///
  static Future<Id4meDnsDataWithLoginHint> getDataFromDns(String id4me,
      {dnssec = false}) async {
    if (!Id4meValidator.isValidUserid(id4me)) {
      throw Id4meIdentifierFormatException(
          message: 'ID4me identifier has wrong format: ' + id4me);
    }
    String loginHint;
    var email = EmailUtils.parseEmailAddress(id4me);
    if (email != null) {
      id4me =
          convertSha256(email.local) + '._openid.' + email.domain.toString();
      loginHint = email.local + '.' + email.domain.toString();
    } else {
      loginHint = id4me;
      id4me = '_openid.' + id4me;
    }

    var domain = id4me.endsWith('.') ? id4me : id4me + '.';
    List<RRecord> records;
    try {
      records =
          await DnsUtils.lookupRecord(domain, RRecordType.TXT, dnssec: dnssec);
    } catch (e) {
      return null;
    }

    var dnsData = getId4meDnsDataFromRRecords(records);
    if (dnsData == null) {
      throw DnsDataNotParseableException();
    }

    return Id4meDnsDataWithLoginHint(dnsData, loginHint);
  }

  ///
  /// Convert the given String [s] to sha256 an return only the first 56 chars.
  ///
  static String convertSha256(String s) {
    var bytes = utf8.encode(s);
    var hash = sha256.convert(bytes).toString();
    return hash.substring(0, 56);
  }

  ///
  /// Converts the DNS record to an instance of Id4meDnsData. Returns null if converting fails.
  ///
  static Id4meDnsData getId4meDnsDataFromRRecords(List<RRecord> records) {
    String v;
    String iau;
    String iag;

    records.forEach((r) {
      if (r.name.startsWith('_openid')) {
        var data = r.data.replaceAll('\'', '');
        var values = data.split(';');
        values.forEach((value) {
          var e = value.trim().split('=');
          if (e.length == 2) {
            if ('v' == e[0]) {
              if (v != null) {
                Logger(TAG)
                    .info('More than one v field found in TXT RR: ${r.data}');
                return null;
              } else {
                v = e[1].trim();
              }
            }
            if ('iss' == e[0]) {
              if (iau != null) {
                Logger(TAG)
                    .info('More than one iss field found in TXT RR: ${r.data}');
                return null;
              } else {
                iau = e[1].trim();
              }
            }
            if ('clp' == e[0]) {
              if (iag != null) {
                Logger(TAG)
                    .info('More than one clp field found in TXT RR: ${r.data}');
                throw Exception(
                    'More than one clp field found in TXT RR: ${r.data}');
              } else {
                iag = e[1].trim();
              }
            }

            if ('iau' == e[0]) {
              if (iau != null) {
                Logger(TAG)
                    .info('More than one iss field found in TXT RR: ${r.data}');
                throw Exception(
                    'More than one iss field found in TXT RR: ${r.data}');
              } else {
                iau = e[1].trim();
              }
            }
            if ('iag' == e[0]) {
              if (iag != null) {
                Logger(TAG)
                    .info('More than one clp field found in TXT RR: ${r.data}');
                throw Exception(
                    'More than one clp field found in TXT RR: ${r.data}');
              } else {
                iag = e[1].trim();
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
