import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/user_info_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserListBuilder extends StatelessWidget {
  UserListBuilder(Stream docStream, Function onTouch) {
    docuStream = docStream;
    onTouchFun = onTouch;
  }
  Stream docuStream;
  Function onTouchFun;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: docuStream,
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return _buildList(snapshot.data);
        }
        else {
          return ListView(
            children: <Widget>[
              ListTile(
                //onTap: Add friend activity thing,
                subtitle: Text(
                  'Add some friends!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }
  Widget _buildList(QuerySnapshot snapshot) {
    return ListView.builder(
      itemCount: snapshot.documents.length * 2,
      itemBuilder: (context, i) {
        if(i.isOdd) return Divider();
        int index = i~/2;
        return _buildRow(snapshot.documents[index], context);
      },
    );
  }
  Widget _buildRow(DocumentSnapshot userDoc, BuildContext context) {
    return ListTile(
      title: Text(userDoc.data['nickname']),
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(userDoc.data['photoUrl']),
        radius: 20,
      ),
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return UserInfoScreen(userDoc.reference);
              },
            )
        );
      },
    );
  }
}