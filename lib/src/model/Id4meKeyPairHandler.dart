part of id4me_api;

class Id4meKeyPairHandler {
  //keyPair = null;
  String pubKey;
  String privKey;

  Id4meKeyPairHandler(String pubKey, String privKey) {
    this.privKey = privKey;
    this.pubKey = pubKey;
    /*
  PublicKey pub_key = getPemPublicKey(pub_key_file);
  PrivateKey priv_key = getPemPrivateKey(priv_key_file);
  keyPair = new KeyPair(pub_key, priv_key);
  */
  }
}
