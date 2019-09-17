import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/user_info_screen.dart';
import 'package:complimentary/home_screen.dart';
import 'package:complimentary/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/logoGifFast.gif',
                height: 200,
                gaplessPlayback: true,
              ),
              SizedBox(height: 50),
              _signInButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        signInWithGoogle().then((result) {
          if(result) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return HomeScreen();
                },
              ),
            );
          }
          else {
            showDialog(context: context,
              barrierDismissible: false,
              builder: (context) {
                String username = "";
                return AlertDialog(
                  title: Text('Set your Username'),
                  content: TextField(
                    onChanged: (value) { username = value; },
                    decoration: InputDecoration.collapsed(hintText: 'Username'),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Submit'),
                      onPressed: () {
                        Firestore.instance.collection('users').where('name', isEqualTo: username).getDocuments().then((docData) {
                          if(docData.documents.length == 0) {
                            Firestore.instance.collection('users').document(user.uid).updateData({'name' : username});
                            Navigator.pop(context, true);
                          }
                          else {
                            Fluttertoast.showToast(msg: 'That username is taken.');
                          }
                        });
                      },
                    )
                  ],
                );
              }
            ).then((after) {
              if(after) {
                Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) {
                          return HomeScreen();
                        }
                    )
                );
              }
            });
          }
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}