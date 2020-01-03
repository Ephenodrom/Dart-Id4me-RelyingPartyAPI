part of id4me_api;

///
/// An exception for errors while fetching the _openid TXT record
///
class DnsResolveException implements Exception {
  final String message;

  DnsResolveException({this.message = 'Could not resolve dns data'});

  @override
  String toString() => message;
}
