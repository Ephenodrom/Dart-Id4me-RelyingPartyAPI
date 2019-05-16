import 'package:basic_utils/src/model/RRecord.dart';
import 'package:id4me_relying_party_api/id4me_relying_party_api.dart';
import "package:test/test.dart";

void main() {
  test('Test getId4meDnsDataFromRRecords', () async {
    List<RRecord> records = [];
    RRecord r = new RRecord(
        name: "_openid.example.com",
        rType: 16,
        TTL: 300,
        data: "v=OID1;iss=auth.freedom-id.de;clp=identityagent.de");
    records.add(r);
    Id4meDnsData data = Id4meResolver.getId4meDnsDataFromRRecords(records);
    expect(data.v, "OID1");
    expect(data.iau, "auth.freedom-id.de");
    expect(data.iag, "identityagent.de");
  });

  test('Test getId4meDnsDataFromRRecords2', () async {
    List<RRecord> records = [];

    RRecord r = new RRecord(
        name: "_openid.example.com",
        rType: 16,
        TTL: 300,
        data: '"v=OID1;iss=id.test.denic.de;clp=identityagent.de"');
    records.add(r);
    Id4meDnsData data = Id4meResolver.getId4meDnsDataFromRRecords(records);
    expect(data.v, "OID1");
    expect(data.iau, "id.test.denic.de");
    expect(data.iag, "identityagent.de");
  });

  test('Test convertSha256', () async {
    String hash = Id4meResolver.convertSha256("jon.doe");
    expect(hash, "24f4ef2281fc620c745d74bf354c18b61987c23e645a7441c25254a9");
  });
}
