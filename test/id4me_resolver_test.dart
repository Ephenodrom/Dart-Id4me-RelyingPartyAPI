import 'package:basic_utils/src/model/RRecord.dart';
import 'package:id4me_api/id4me_api.dart';
import "package:test/test.dart";

void main() {
  test('Test lookupRecord', () async {
    List<RRecord> records = [];
    RRecord r = new RRecord(
        name: "_openid.example.com",
        type: 16,
        TTL: 300,
        data: "v=OID1;iss=auth.freedom-id.de;clp=identityagent.de");
    records.add(r);
    Id4meDnsData data = Id4meResolver.getId4meDnsDataFromRRecords(records);
    expect(data.v, "OID1");
    expect(data.iau, "auth.freedom-id.de");
    expect(data.iag, "identityagent.de");
  });

  test('Test lookupRecord2', () async {
    List<RRecord> records = [];

    RRecord r = new RRecord(
        name: "_openid.example.com",
        type: 16,
        TTL: 300,
        data: '"v=OID1;iss=id.test.denic.de;clp=identityagent.de"');
    records.add(r);
    Id4meDnsData data = Id4meResolver.getId4meDnsDataFromRRecords(records);
    expect(data.v, "OID1");
    expect(data.iau, "id.test.denic.de");
    expect(data.iag, "identityagent.de");
  });
}
