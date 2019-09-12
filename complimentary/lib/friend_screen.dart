import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/bulid_users_screen.dart';
import 'package:complimentary/const.dart';
import 'package:complimentary/new_compliment_screen.dart';
import 'package:complimentary/sign_in.dart';
import 'package:complimentary/user_info_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FriendScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Friends'),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            bottom: TabBar(tabs: <Tab>[
              Tab(text: 'Your Friends'),
              Tab(text: 'Add Friends'),
            ]),
          ),
          body: TabBarView(children: [ FriendPage(), UserPage()]),
        ),
      ),
    );
  }
}
class FriendPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return FriendPageState();
  }
}
class FriendPageState extends State<FriendPage> with AutomaticKeepAliveClientMixin<FriendPage>{
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document(user.uid)
            .get()
            .asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildList(snapshot.data['friends']??List());
          }
          return ListTile(
            subtitle: Text('There was a problem.'),
          );
        });
  }
  Widget _buildList(List docRefs) {
    if(docRefs.length == 0) {
      return ListTile(
        subtitle: Text('Add some friends!', textAlign: TextAlign.center,),
      );
    }
    return ListView.builder(
      itemCount: docRefs.length * 2,
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();
        int index = i ~/ 2;
        return _buildRow(docRefs[index], context);
      },
    );
  }

  StatefulWidget _buildRow(DocumentReference docRef, BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: docRef.get().asStream(),
      builder: (context, userDoc) {
        if (userDoc.hasData) {
          return ListTile(
            title: Text(userDoc.data['name']??'Error'),
            leading: userDoc.data == null? null : CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(userDoc.data['imageUrl']),
              radius: 20,
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return UserInfoScreen(docRef);
                },
              ));
            },
            trailing: IconButton(
              icon: Icon(
                Icons.send,
                color: themeColor,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return NewComplimentScreen(docSnap: userDoc.data);
                    }
                  )
                );
              },
            ),
          );
        } else {
          return Divider(color: Colors.white,);
        }
      },
    );
  }
}
class UserPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return UserPageState();
  }
}
class UserPageState extends State<UserPage> with AutomaticKeepAliveClientMixin<UserPage>{
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return UserListBuilder(Firestore.instance.collection('users').getDocuments().asStream(), () {} );
  }
}
