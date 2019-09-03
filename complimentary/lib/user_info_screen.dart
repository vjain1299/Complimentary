import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/login.dart';
import 'package:complimentary/new_compliment_screen.dart';
import 'package:complimentary/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                leading: IconButton(icon:Icon(Icons.arrow_back),
                  onPressed:() => Navigator.pop(context, false),
                )
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.blue[100], Colors.green[100]],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        snapshot.data['photoUrl'],
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
                      snapshot.data['nickname'],
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold
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
                          fontSize: 25,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 40),
                    (snapshot.data['id'] != user.uid)?
                    RaisedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return NewComplimentScreen(Firestore.instance.collection('users').document(snapshot.data['id']));
                              },
                            )
                        );
                      },
                      color: Colors.deepPurple,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Send Compliment',
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                      ),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    )
                        :
                    RaisedButton(
                      onPressed: () {
                        signOutGoogle();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) {
                              return LoginPage();
                            }), ModalRoute.withName('/'));
                      },
                      color: Colors.deepPurple,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                      ),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    )
                  ],
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
