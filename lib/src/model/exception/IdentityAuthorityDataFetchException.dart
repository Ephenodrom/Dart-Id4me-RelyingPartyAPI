part of id4me_api;

///
/// An exception for error while fetching the Identity Authority data
///
class IdentityAuthorityDataFetchException implements Exception {
  final String message;

  IdentityAuthorityDataFetchException(
      {this.message = 'Could not fetch Identity Authority data'});

  @override
  String toString() => message;
}
