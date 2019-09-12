import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendSelector extends StatelessWidget{
  FriendSelector();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a recipient'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back
          ),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
      ),
      body: FriendSelectorBuilder(),
    );
  }
}
class FriendSelectorBuilder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FriendSelectorBuilderState();
  }
}
class FriendSelectorBuilderState extends State<FriendSelectorBuilder> {
  String query = "";
  @override
  Widget build(BuildContext context) {
    return buildFriendList();
  }
  Widget buildFriendList() {
    return StreamBuilder<DocumentSnapshot>(
      stream : Firestore.instance.collection('users').document(user.uid).get().asStream(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          var friendList = List.castFrom(snapshot.data['friends']);
          return ListView.builder(
              itemCount: friendList.length * 2 + 2,
              itemBuilder: (context, index) {
                if(index == 0) {
                  return ListTile(
                      title: TextField(
                        decoration: InputDecoration.collapsed(hintText: 'Search'),
                        controller: TextEditingController(text: query),
                        onChanged: (value) {
                          if(query == "") return;
                          setState(() {
                            query = value;
                          });
                        },
                      )
                  );
                }
                else if(index.isOdd) {
                  return Divider();
                }
                else {
                  int i = (index - 2) ~/ 2;
                  return buildListItem(friendList[i]);
                }
              }
          );
        }
        else return LinearProgressIndicator();
      },
    );
  }
  Widget buildListItem(DocumentReference userRef) {
    return StreamBuilder(
      stream: userRef.get().asStream(),
      builder: (context, userData) {
        if(userData.hasData) {
          if(!(userData.data['name']??"").toString().contains(query)) {
            return Divider(height: 0, color: Colors.transparent,);
          }
          return ListTile(
            title: Text(userData.data['name']??'Error'),
            leading: userData.data == null? null : CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(
                  userData.data['imageUrl'],
                )
            ),
            onTap: () {
              Navigator.of(context).pop(userData.data);
            },
          );
        }
        else {
          return Divider(height: 0, color: Colors.transparent,);
        }
      }
    );
  }
}