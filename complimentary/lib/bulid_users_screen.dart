import 'package:cloud_firestore/cloud_firestore.dart';
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
                  docuStream = Firestore.instance.collection('users').orderBy('nickname').startAt([value]).endAt([value + '\uf8ff']).getDocuments().asStream();
                });
              },
            ),
          );
        }
        if(i.isEven) return Divider();
        int index = (i-1)~/2 - 1;
        return _buildRow(snapshot.documents[index], context);
      },
    );
  }
  Widget _buildRow(DocumentSnapshot userDoc, BuildContext context) {
    List requests = userDoc.data['requests'];
    List friends = userDoc.data['friends']??List();
    var userRef = Firestore.instance.collection('users').document(user.uid);
    bool isAlreadyRequested = requests.contains(userRef) || friends.contains(userRef);
    return ListTile(
      title: Text(userDoc.data['nickname']),
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(userDoc.data['photoUrl']),
        radius: 20,
      ),
      trailing: isAlreadyRequested? Icon(Icons.check, color: Colors.green,) :
      IconButton(
        icon: Icon(
          Icons.add,
          color: Colors.blue,
        ),
        onPressed: () {
          var newData = [];
          newData.addAll(requests);
          newData.add(Firestore.instance.collection('users').document(user.uid));
          userDoc.reference.setData({'requests': newData}, merge: true);
          setState(() {});
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