import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/bulid_users_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AllUsersScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friends'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body:
      UserListBuilder(Firestore.instance.collection('users'), onTouched),
    );
  }
  void onTouched() {
    print('tapped');
  }
}