import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserListBuilder extends StatelessWidget {
  UserListBuilder(CollectionReference collRef, Function onTouch) {
    colRef = collRef;
    onTouchFun = onTouch;
  }
  CollectionReference colRef;
  Function onTouchFun;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: colRef.getDocuments().asStream(),
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
      itemCount: snapshot.documents.length,
      itemBuilder: (context, i) {
        if(i.isOdd) return Divider();
        int index = i~/2;
        return _buildRow(snapshot.documents[index]);
      },
    );
  }
  Widget _buildRow(DocumentSnapshot userDoc) {
    return ListTile(
      title: Text(userDoc.data['nickname']),
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(userDoc.data['photoUrl']),
        radius: 20,
      ),
      onTap: onTouchFun,
    );
  }
}