import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/user_info_screen.dart';
import 'package:complimentary/sign_in.dart';
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
            .getDocuments()
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
      padding: const EdgeInsets.all(4.0),
      itemCount: snapshot.documents.length * 2,
      itemBuilder: (context, i) {
        if (i.isOdd) {
          return Divider();
        } else {
          final index = i ~/ 2;
          return _buildRow(snapshot.documents[index]);
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
                  Text(
                      message,
                    style: TextStyle(
                      fontSize: 18
                    ),
                  )
                ]))));
  }
}
