part of id4me_api;

///
/// An exception for missing mandatory claims
///
class MandatoryClaimsException implements Exception {
  final String message;

  MandatoryClaimsException({this.message = "Mandatory claim not found!"});

  String toString() => message;
}
