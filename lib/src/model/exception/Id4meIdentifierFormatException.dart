part of id4me_api;

///
/// An exception for wrong id4me identifier formats
///
class Id4meIdentifierFormatException implements Exception {
  final String message;

  Id4meIdentifierFormatException(
      {this.message = 'ID4me identifier has wrong format'});

  @override
  String toString() => message;
}
