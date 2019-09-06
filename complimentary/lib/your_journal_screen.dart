import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/sign_in.dart';
import 'package:complimentary/sign_in.dart' as prefix0;
import 'package:complimentary/user_info_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JournalScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return JournalScreenState();
  }
}
class JournalScreenState extends State<JournalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Journal'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              String temp = "";
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Add an entry'),
                    content: TextField(
                      onChanged: (value) {
                        temp = value;
                      },
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      FlatButton(
                        child: Text('Add'),
                        onPressed: () {
                          var docuRef = Firestore.instance.collection('users').document(user.uid).collection('journal').document(DateTime.now().millisecondsSinceEpoch.toString());
                          docuRef.setData({ 'text' : temp });
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: _buildJournalList(),
    );
  }
  Widget _buildJournalList() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').document(user.uid).collection('journal').getDocuments().asStream(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return ListView.builder(
            itemBuilder: (context, i) {
              int index = i~/2;
              if(i.isOdd) return Divider(height: 2);
              return Dismissible(
                key: Key(snapshot.data.documents[index].documentID),
                child: _buildJournalItem(snapshot.data.documents[index]),
                onDismissed: (direction) {
                  snapshot.data.documents[index].reference.setData({'isInJournal' : false}, merge: true);
                  Firestore.instance.collection('users').document(user.uid).collection('journal').document(snapshot.data.documents[index].documentID).delete();
                  setState(() {});
                },
              );
            },
            itemCount: snapshot.data.documents.length * 2,
          );
        }
        else {
          return LinearProgressIndicator();
        }
      }
    );
  }
  Widget _buildJournalItem(DocumentSnapshot snap) {
    final mappedData = snap.data;
    final message = mappedData['text']??"";
    final imageUrl = mappedData['imageUrl']??user.photoUrl;
    final displayName = mappedData['name']??name;
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
                                    return UserInfoScreen(snap.data['user']??Firestore.instance.collection('users').document(user.uid));
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
                      displayName,
                      style: TextStyle(
                          fontSize: 24
                      ),
                    ),
                  ]
                  ),
                  Padding(
                      padding: EdgeInsets.all(8.0)
                  ),
                  Text(
                    message,
                    style: TextStyle(
                        fontSize: 18
                    ),
                  )
                ]))));
  }
}