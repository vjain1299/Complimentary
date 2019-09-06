import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewComplimentScreen extends StatelessWidget {
  NewComplimentScreen(DocumentReference docuRef) {
    docRef = docuRef.collection('stream').document(DateTime.now().millisecondsSinceEpoch.toString());
  }
  DocumentReference docRef;
  @override
  Widget build(BuildContext context) {
    var compliment = "";
    return Scaffold(
      appBar: AppBar(
        title: Text('New Compliment'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon:Icon(Icons.arrow_back),
          onPressed:() => Navigator.pop(context, false),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          docRef.setData({
            'user': Firestore.instance.collection('users').document(user.uid),
            'text': compliment,
            'archived' : false,
            'imageUrl' : user.photoUrl,
            'name' : name,
            'createdAt' : docRef.documentID
          });
          Navigator.pop(context, false);
        },
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.check,
          size: 20,
          color: Colors.white,
        )
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          maxLines: null,
          onChanged: (value) {
            compliment = value;
          },
        ),
      ),
    );
  }
}