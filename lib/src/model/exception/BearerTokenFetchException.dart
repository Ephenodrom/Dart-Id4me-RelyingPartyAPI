part of id4me_api;

///
/// An exception for errors while fetching the bearer token
///
class BearerTokenFetchException implements Exception {
  final String message;

  BearerTokenFetchException(
      {this.message = "Could not fetch bearer token from Identity Authiroty"});

  String toString() => message;
}
