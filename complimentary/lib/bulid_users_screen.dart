import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:complimentary/sign_in.dart';
import 'package:complimentary/user_info_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserListBuilder extends StatefulWidget {
  UserListBuilder(Stream docStream, Function onTouch) {
    docuStream = docStream;
    onTouchFun = onTouch;
  }
  Stream docuStream;
  Function onTouchFun;
  @override
  State<StatefulWidget> createState() {
    return UserListState(docuStream);
  }
}
class UserListState extends State<UserListBuilder> {
  @override
  UserListState(Stream docStream) {
    docuStream = docStream;
  }
  Stream docuStream;
  Function onTouchFun;
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
                  'No Users Found',
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
      itemCount: snapshot.documents.length * 2 + 2,
      itemBuilder: (context, i) {
        if(i == 0) {
          return Divider(color: Colors.transparent,);
        }
        if(i == 1) {
          return ListTile(
            title: TextField(
              decoration: InputDecoration.collapsed(
                  hintText: 'Search',
              ),
              onChanged: (value) {
                setState(() {
                  if(value == "") docuStream = Firestore.instance.collection('users').getDocuments().asStream();
                  else docuStream = Firestore.instance.collection('users').orderBy('name').startAt([value]).endAt([value + '\uf8ff']).getDocuments().asStream();
                });
              },
            ),
          );
        }
        if(i.isEven) return Divider();
        int index = (i-1)~/2 - 1;
        return UserTileBuilder(snapshot.documents[index]);
      },
    );
  }
}
class UserTileBuilder extends StatefulWidget {
  UserTileBuilder(this.snapshot);
  final DocumentSnapshot snapshot;
  @override
  State<StatefulWidget> createState() => UserTileState(snapshot);
}
class UserTileState extends State<UserTileBuilder> {
  UserTileState(this.userDoc);
  final DocumentSnapshot userDoc;
  bool isRequested;
  List requests;
  List friends;
  @override
  void initState() {
    requests = userDoc.data['requests']??List();
    friends = userDoc.data['friends']??List();
    var userRef = Firestore.instance.collection('users').document(user.uid);
    isRequested = requests.contains(userRef) || friends.contains(userRef);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(userDoc.data['name']),
      subtitle: Text(userDoc.data['realName']??''),
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(userDoc.data['imageUrl']),
        radius: 20,
      ),
      trailing: isRequested? Icon(Icons.check, color: Colors.green,) :
      IconButton(
        icon: Icon(
          Icons.add,
          color: Colors.blue,
        ),
        onPressed: () {
          HttpsCallable newRequest = CloudFunctions.instance.getHttpsCallable(functionName: 'newRequest');
          var data = HashMap.of({'name' : name, 'pushID' : userDoc.data['notificationID'], 'imageUrl' : user.photoUrl});
          newRequest.call(data);
          var newData = [];
          newData.addAll(requests);
          newData.add(Firestore.instance.collection('users').document(user.uid));
          userDoc.reference.setData({'requests': newData}, merge: true);
          setState(() {
            isRequested = true;
          });
        },
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