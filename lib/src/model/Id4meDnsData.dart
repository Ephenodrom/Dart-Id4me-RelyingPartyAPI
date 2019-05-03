part of id4me_api;

///
/// Representing the dns data for id4me
///
class Id4meDnsData {
  /// The id4me record
  String v;

  /// Hostname of the Identity Authority
  String iau;

  /// Hostname of the Identity Agent
  String iag;

  Id4meDnsData(this.v, this.iau, this.iag);
}
