part of id4me_api;

///
/// Representing the dns data for id4me
///
class Id4meDnsData {
  /// The id4me record
  String v = null;

  /// Hostname of the Identity Authority
  String iau = null;

  /// Hostname of the Identity Agent
  String iag = null;

  Id4meDnsData(this.v, this.iau, this.iag);
}
