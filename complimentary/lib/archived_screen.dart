import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/sign_in.dart';
import 'package:complimentary/user_info_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ArchivedScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ArchivedScreenState();

}
class ArchivedScreenState extends State<ArchivedScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Archived Compliments')
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
            .where('archived', isEqualTo: true).getDocuments()
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
              Firestore.instance.collection('users').document(user.uid).collection('stream').document(snapshot.documents[index].documentID).setData({'archived': false}, merge: true);
              setState(() {
                snapshot.documents.removeAt(index);
              });
              Scaffold
                  .of(context)
                  .showSnackBar(
                  SnackBar(content: Text("Compliment unarchived.")));
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
                    IconButton(
                      icon: Icon(
                        Icons.delete_forever,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Confirm Delete"),
                              content: Text("Are you sure you want to delete this compliment?"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Yes'),
                                  onPressed: () {
                                    snap.reference.delete();
                                    Navigator.of(context).pop(false);
                                    setState(() {});
                                  },
                                ),
                                FlatButton(
                                  child: Text('No'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                )
                              ],
                            );
                          }
                        );
                      },
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
}