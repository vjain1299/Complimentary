import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser user;
String name = user.displayName;
final GoogleSignIn googleSignIn = GoogleSignIn();
Future<bool> signInWithGoogle() async {
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
      'realName': user.displayName,
      'imageUrl': user.photoUrl,
      'id': user.uid,
      'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'friends' : List(),
      'requests' : List(),
      'email' : user.email,
    });
    return false;
  }
  else {
    name = documents[0].data['name']??user.displayName;
    themeColor = Color(documents[0].data['preferredColor']??themeColor.value);
    affirmations = documents[0].data['affirmations']??false;
  }
  return true;
}

void signOutGoogle() async{
  await googleSignIn.signOut();

  print("User Sign Out");
}

