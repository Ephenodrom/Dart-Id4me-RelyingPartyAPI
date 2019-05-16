part of id4me_api;

///
/// An exception for a missing bearer token
///
class BearerTokenNotFoundException implements Exception {
  final String message;

  BearerTokenNotFoundException(
      {this.message = "Bearer token not found in response"});

  String toString() => message;
}
