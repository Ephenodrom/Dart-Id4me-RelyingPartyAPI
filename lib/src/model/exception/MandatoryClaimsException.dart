part of id4me_api;

///
/// An exception for missing mandatory claims
///
class MandatoryClaimsException implements Exception {
  final String message;

  MandatoryClaimsException({this.message = 'Mandatory claim not found!'});

  @override
  String toString() => message;
}
