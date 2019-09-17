import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:complimentary/const.dart';
import 'package:complimentary/login.dart';
import 'package:complimentary/new_compliment_screen.dart';
import 'package:complimentary/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserInfoScreen extends StatelessWidget {
  DocumentReference _user;
  UserInfoScreen(DocumentReference user) {
    _user = user;
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _user.get().asStream(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: true,
                //`true` if you want Flutter to automatically add Back Button when needed,
                //or `false` if you want to force your own back button every where
                title: Text('User Info'),
                elevation: 0,
                backgroundColor: themeColor,
                leading: IconButton(icon:Icon(Icons.arrow_back),
                  onPressed:() => Navigator.pop(context, false),
                ),
            ),
            body: Container(
              color: themeColor.withAlpha(50),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          snapshot.data['imageUrl'],
                        ),
                        radius: 60,
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(height: 40),
                      Text(
                        'NAME',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      Text(
                        snapshot.data['realName'],
                        style: TextStyle(
                            fontSize: min(56, 560/snapshot.data['realName'].toString().length),
                            color: Colors.black,
                            fontWeight: FontWeight.w300
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        'USERNAME',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      Text(
                        snapshot.data['name'],
                        style: TextStyle(
                            fontSize: min(24, 240/snapshot.data['name'].toString().length),
                            color: Colors.black,
                            fontWeight: FontWeight.w300
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'EMAIL',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      Text(
                        snapshot.data['email'],
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w300),
                      ),
                      SizedBox(height: 40),
                      ActionButton(snapshot.data),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        else {
          return LinearProgressIndicator();
        }
      }
    );
  }
}
class ActionButton extends StatefulWidget {
  ActionButton(this.snapshot);
  final DocumentSnapshot snapshot;
  @override
  State<StatefulWidget> createState() => ActionButtonState(snapshot);
}
class ActionButtonState extends State<ActionButton> {
  ActionButtonState(this.snapshot);
  final DocumentSnapshot snapshot;
  bool isUserRequested;
  bool isFriend = false;
  List friends;
  @override
  void initState() {
    friends = snapshot.data['friends']??List();
    isUserRequested = List.castFrom(snapshot.data['requests']??List()).contains(Firestore.instance.collection('users').document(user.uid));
    isFriend = (snapshot.data['friends']??List()).contains(Firestore.instance.collection('users').document(user.uid));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if(snapshot.data['id'] == user.uid) {
      return FlatButton(
        onPressed: () {
          signOutGoogle();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
                return LoginPage();
              }), ModalRoute.withName('/'));
        },
        color: themeColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Sign Out',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)),
      );
    }
    else if(isFriend??false) {
      return Row(
        children: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return NewComplimentScreen(docSnap: snapshot);
                    },
                  )
              );
            },
            color: themeColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Send Compliment',
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)),
          ),
          Spacer(),
          FlatButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content: Text('Are you sure you want to unfriend ${snapshot.data['name']}?'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Yes'),
                          onPressed: () {
                            Firestore.instance.collection('users').document(user.uid).updateData({'friends' : FieldValue.arrayRemove([snapshot.reference])});
                            snapshot.reference.updateData({'friends' : FieldValue.arrayRemove([Firestore.instance.collection('users').document(user.uid)])});
                            Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        )
                      ],
                    );
                  }
              ).then((result) {
                print(result);
                if(result) {
                  setState(() {
                    isFriend = false;
                  });
                }
              });
            },
            color: themeColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Unfriend',
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)),
          )
        ],
      );
    }
    else {
      return FlatButton(
        onPressed: () {
          if(isUserRequested) {
            SnackBar(
              content: Text(
                "You've already sent a request to this user",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: themeColor,
            );
            return;
          }
          List newRequests = [];
          newRequests.addAll(snapshot.data['requests'] ?? List());
          newRequests.add(Firestore.instance.collection('users').document(user.uid));
          Firestore.instance.collection('users').document(snapshot.data['id']).setData({ 'requests' : newRequests}, merge: true);
          HttpsCallable newRequest = CloudFunctions.instance.getHttpsCallable(functionName: 'newRequest');
          var data = HashMap.of({'name' : name, 'pushID' : snapshot.data['notificationID'], 'imageUrl' : user.photoUrl});
          newRequest.call(data);
          setState(() {
            isUserRequested = true;
          });
        },
        color: isUserRequested? Colors.grey : themeColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            isUserRequested? 'Request Sent' : 'Add Friend',
            style: TextStyle(fontSize: 25, color: Colors.white),
          ),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)),
      );
    }
  }
}
