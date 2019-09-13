import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser user;
String name = user.displayName;
final GoogleSignIn googleSignIn = GoogleSignIn();
Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
  await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  _auth.signInWithCredential(credential);
  user = (await _auth.signInWithCredential(credential)).user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);
  final QuerySnapshot result =
  await Firestore.instance.collection('users').where('id', isEqualTo: user.uid).getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  if (documents.length == 0) {
    // Update data to server if new user
    Firestore.instance.collection('users').document(user.uid).setData({
      'name': name,
      'imageUrl': user.photoUrl,
      'id': user.uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'friends' : List(),
      'requests' : List(),
      'email' : user.email,
    });
  }
  else {
    name = documents[0].data['name']??user.displayName;
    themeColor = Color(documents[0].data['preferredColor'])??themeColor;
  }
  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async{
  await googleSignIn.signOut();

  print("User Sign Out");
}

