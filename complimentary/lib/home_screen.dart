import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/all_users_screen.dart';
import 'package:complimentary/archived_screen.dart';
import 'package:complimentary/friend_request_screen.dart';
import 'package:complimentary/friend_screen.dart';
import 'package:complimentary/settings_screen.dart';
import 'package:complimentary/user_info_screen.dart';
import 'package:complimentary/sign_in.dart';
import 'package:complimentary/your_journal_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Stream",
      theme: ThemeData(primaryColor: Colors.blue),
      home: MyStream(),
    );
  }
}

class MyStream extends StatefulWidget {
  @override
  MyStreamState createState() => MyStreamState();
}

class MyStreamState extends State<MyStream> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _makeDrawer(),
      appBar: AppBar(title: Text('Your Stream')
          //Add in side menu here
          ),
      body: _buildStream(),
    );
  }

  Widget _buildStream() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(user.uid)
            .collection('stream')
            .where('archived', isEqualTo: false).getDocuments()
            .asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return LinearProgressIndicator();
          } else if (snapshot.hasData) {
            return _buildListFromStream(snapshot.data);
          } else {
            return LinearProgressIndicator();
          }
        });
  }

  Widget _buildListFromStream(QuerySnapshot snapshot) {
    return ListView.builder(
      itemCount: snapshot.documents.length * 2,
      itemBuilder: (context, i) {
        if (i.isOdd) {
          return Divider(height: 2);
        } else {
          final index = i ~/ 2;
          return Dismissible(
            key: Key(snapshot.documents[index].documentID),
            onDismissed: (direction) {
              // Remove the item from the data source.
              Firestore.instance.collection('users').document(user.uid).collection('stream').document(snapshot.documents[index].documentID).setData({'archived': true}, merge: true);
              setState(() {
                snapshot.documents.removeAt(index);
              });
              Scaffold
                  .of(context)
                  .showSnackBar(
                  SnackBar(content: Text("Compliment dismissed")));
            },
             child: _buildRow(snapshot.documents[index]),
          );
        }
      },
    );
  }

  Widget _buildRow(DocumentSnapshot snap) {
    final mappedData = snap.data;
    final message = mappedData['text'];
    final imageUrl = mappedData['imageUrl'];
    final name = mappedData['name'];
    return Card(
        color: Colors.white,
        //clipBehavior: Clip.none,
        elevation: 5,
        child: InkWell(
            splashColor: Colors.green.withAlpha(30),
            onTap: () {
              print('Card tapped.');
            },
            child: Container(
                margin: EdgeInsets.all(16.0),
                width: 300,
                child: Column(children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) {
                                  return UserInfoScreen(snap.data['user']);
                                }));
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        radius: 30,
                        backgroundColor: Colors.transparent,
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0)
                    ),
                    Text(
                      name,
                      style: TextStyle(
                          fontSize: 24
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        print('Pressed');
                        },
                        child: Text(
                        'Reply',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 24
                        ),
                      )
                    )
                  ]
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0)
                  ),
                  ListTile(
                    title: Text(
                      message,
                      style: TextStyle(
                          fontSize: 18
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                          (!(snap.data['isInJournal']??true))?
                          Icons.bookmark_border :
                          Icons.bookmark
                      ),
                      onPressed: () {
                        if(!(snap.data['isInJournal']??false)) {
                          Map data = snap.data;
                          data['docRef'] = snap.reference;
                          Firestore.instance.collection('users').document(
                              user.uid).collection('journal').document(snap.documentID).setData(data);
                          snap.reference.setData({'isInJournal' : true}, merge: true);
                        }
                        else {
                          snap.reference.setData({'isInJournal' : false}, merge: true);
                          Firestore.instance.collection('users').document(user.uid).collection('journal').document(snap.documentID).delete();
                        }
                        setState(() {});
                      },
                    ),
                  )

                ]))));
  }
  Drawer _makeDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) {
                              return UserInfoScreen(Firestore.instance.collection('users').document(user.uid));
                            },
                        )
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl),
                    backgroundColor: Colors.transparent,
                    radius: 40,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return UserInfoScreen(Firestore.instance.collection('users').document(user.uid));
                          },
                        )
                    );
                  },
                  child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      )
                  ),
                ),
              ]
            ),
            decoration: BoxDecoration(
              color: Colors.blue
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: Colors.blue,
              size: 30,
            ),
            title: Text(
                'Home',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.people,
              color: Colors.blue,
              size: 30,
            ),
            title: Text(
              'Friends',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) {
                        return FriendScreen();
                      }));
            }
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.people_outline,
              color: Colors.blue,
              size: 30,
            ),
            title: Text(
              'Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return FriendRequestsScreen();
                  }
                )
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.book,
              color: Colors.blue,
              size: 30,
            ),
            title: Text(
              'Your Journal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) {
                        return JournalScreen();
                      }
                  )
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.archive,
              color: Colors.blue,
              size: 30,
            ),
            title: Text(
              'Archived',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) {
                        return ArchivedScreen();
                      }
                  )
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Colors.blue,
              size: 30,
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) {
                        return SettingsScreen();
                      }
                  )
              );
            },
          ),
          Divider(),
        ]
      )
    );
  }
}
