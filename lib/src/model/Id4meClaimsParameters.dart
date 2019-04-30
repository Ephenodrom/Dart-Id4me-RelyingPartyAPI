part of id4me_api;

class Id4meClaimsParameters {
  List<Entry> entries = [];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> userinfo = {};
    for (Entry e in entries) {
      Map<String, dynamic> reasonEssential = {};
      if (e.reason != null) {
        reasonEssential["reason"] = e.reason;
      }
      if (e.essential != null) {
        reasonEssential["essential"] = e.essential;
      }
      userinfo[e.name] = reasonEssential;
    }
    Map<String, dynamic> wrapper = {};
    wrapper["userinfo"] = userinfo;

    return wrapper;
  }
}
