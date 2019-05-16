part of id4me_api;

///
/// An exception for unparseable dns data
///
class DnsDataNotParseableException implements Exception {
  final String message;

  DnsDataNotParseableException(
      {this.message = "Could not parse Id4meDnsData from TXT record"});

  String toString() => message;
}
