import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/friend_screen.dart';
import 'package:complimentary/sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewComplimentScreen extends StatelessWidget {
  NewComplimentScreen({DocumentSnapshot docuSnap, DocumentReference docuRef} ) {
    docRef = docuRef??docuSnap.reference
        .collection('stream')
        .document(DateTime.now().millisecondsSinceEpoch.toString());
    docSnap = docuSnap;
  }
  DocumentReference docRef;
  DocumentSnapshot docSnap;
  @override
  Widget build(BuildContext context) {
    var compliment = "";
    var prefixList = ['My favorite thing about you is ', "You've always been talented at", ''];
    var prefix = "";
    var userName = docSnap != null? docSnap.data['name'] : 'Yourself';
    var imageUrl = docSnap != null? docSnap.data['imageUrl'] : user.photoUrl;
    return Scaffold(
        appBar: AppBar(
            title: Text('New Compliment'),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              docRef.setData({
                'user':
                    Firestore.instance.collection('users').document(user.uid),
                'text': prefix + compliment,
                'archived': false,
                'imageUrl': user.photoUrl,
                'name': name,
                'createdAt': docRef.documentID
              });
              Navigator.pop(context, false);
            },
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.check,
              size: 20,
              color: Colors.white,
            )),
        body: ListView(children: [
          Divider(color: Colors.white, height: 4),
          ListTile(
            contentPadding: EdgeInsets.all(16.0),
            title: Text('To: $userName'),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.transparent,
              radius: 30,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return FriendScreen();
                  }
                )
              );
            },
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration.collapsed(hintText: 'Write your compliment here'),
              maxLines: null,
              onChanged: (value) {
                compliment = value;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ]));
  }
}
