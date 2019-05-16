part of id4me_api;

///
/// An exception for errors while fetching the user information
///
class UserInfoFetchException implements Exception {
  final String message;

  UserInfoFetchException(
      {this.message = "Could not fetch user data from Identity Agent"});

  String toString() => message;
}
