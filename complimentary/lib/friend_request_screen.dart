import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/bulid_users_screen.dart';
import 'package:complimentary/sign_in.dart';
import 'package:complimentary/user_info_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendRequestsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FriendRequestsState();
  }
}
class FriendRequestsState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    Stream stream = Firestore.instance
        .collection('users')
        .document(user.uid)
        .get()
        .asStream();
    return Scaffold(
        appBar: AppBar(
          title: Text('Friend Requests'),
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _buildList(
                  snapshot.data['requests'], snapshot.data['friends']);
            } else {
              return LinearProgressIndicator();
            }
          },
        ));
  }

  Widget _buildList(List docRefs, List friends) {
    return ListView.builder(
      itemCount: docRefs.length * 2,
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();
        int index = i ~/ 2;
        return _buildRow(docRefs[index], context, docRefs, friends);
      },
    );
  }

  Widget _buildRow(DocumentReference docRef, BuildContext context, List docRefs,
      friendsRefs) {
    List requests = [];
    List friends = [];
    requests.addAll(docRefs);
    requests.addAll(friendsRefs);
    return StreamBuilder<DocumentSnapshot>(
        stream: docRef.get().asStream(),
        builder: (context, userDoc) {
          if (userDoc.hasData) {
            return ListTile(
                title: Text(userDoc.data['nickname']),
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(userDoc.data['photoUrl']),
                  radius: 20,
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return UserInfoScreen(docRef);
                    },
                  ));
                },
                trailing: Container(
                  width: 100,
                  child: Row(children: [
                    IconButton(
                        icon: Icon(
                          Icons.check,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          requests.remove(docRef);
                          friends.add(docRef);
                          Firestore.instance
                              .collection('users')
                              .document(user.uid)
                              .setData({'requests': requests}, merge: true);
                          Firestore.instance
                              .collection('users')
                              .document(user.uid)
                              .setData({'friends': friends}, merge: true);
                          setState(() {
                          });
                        }),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        requests.remove(docRef);
                        Firestore.instance
                            .collection('users')
                            .document(user.uid)
                            .setData({'requests': requests}, merge: true);
                        setState(() {});
                      },
                    )
                  ]),
                ));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}