import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_functions/cloud_functions.dart' as prefix0;
import 'package:complimentary/archived_screen.dart';
import 'package:complimentary/const.dart' as Const;
import 'package:complimentary/endless_suggestions_screen.dart';
import 'package:complimentary/friend_request_screen.dart';
import 'package:complimentary/friend_screen.dart';
import 'package:complimentary/friend_selector.dart';
import 'package:complimentary/new_compliment_screen.dart';
import 'package:complimentary/settings_screen.dart';
import 'package:complimentary/user_info_screen.dart';
import 'package:complimentary/sign_in.dart';
import 'package:complimentary/your_journal_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart' as prefix1;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Stream",
      home: MyStream(),
    );
  }
}

class MyStream extends StatefulWidget {
  @override
  MyStreamState createState() => MyStreamState();
}

class MyStreamState extends State<MyStream> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String _bannerId = Platform.isAndroid?
  //'ca-app-pub-2874072397905886/9050312172': //Real Code
  'ca-app-pub-3940256099942544/6300978111': //Test Code
  //'ca-app-pub-2874072397905886/8018401729';
  'ca-app-pub-3940256099942544/2934735716';
  bool affirmed = false;
  @override
  void dispose() {

    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    affirmed = false;
    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();
    _firebaseMessaging.getToken().then((token) {
      Firestore.instance
          .collection('users')
          .document(user.uid)
          .setData({'notificationID': token}, merge: true);
    });
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
    });
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('Settings Registered: $settings');
    });
  }
  @override
  Widget build(BuildContext context) {
    if(Const.affirmations && !affirmed) Future.delayed(Duration(seconds: 1), () {
      affirmed = true;
      showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('A thought:'),
            content: StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance.collection('prompts').document('affirmations').get().asStream(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData) return CircularProgressIndicator();
                    return Text(
                      ((List.castFrom(snapshot.data.data['affirmationList']??List()))..shuffle()).first??'',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              );
        },
      );
    });
    return RefreshIndicator(
      onRefresh: refresh,
      child: Scaffold(
        drawer: _makeDrawer(),
        appBar: AppBar(
          bottom: PreferredSize(child: AdmobBanner(
            adSize: AdmobBannerSize.BANNER,
            adUnitId: _bannerId,
            listener: (AdmobAdEvent event, Map<String, dynamic> args) {
              print(event);
            },
          ),
          preferredSize: Size(AdmobBannerSize.BANNER.width.toDouble(), AdmobBannerSize.BANNER.height.toDouble()),),
          backgroundColor: Const.themeColor,
          title: Text('Your Stream'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.lightbulb_outline
              ),
              onPressed: () {
                showDialog(context: context,
                  builder: (context) {
                    return getDailyObjectives(context);
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Const.themeColor.withAlpha(255),
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return NewComplimentScreen();
            }));
          },
        ),
        body: _buildStream(),
      ),
    );
  }

  Future<void> refresh() async {
    setState(() {});
  }

  Widget _buildStream() {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(user.uid)
            .collection('stream')
            .where('archived', isEqualTo: false)
            .orderBy('__name__', descending: true)
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
    if (snapshot.documents.length == 0) {
      return Center(
          child: SingleChildScrollView( padding: EdgeInsets.all(32.0) ,child: ListTile(
        title: Text(
          'No new compliments right now...\nTry Complimenting Yourself!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return NewComplimentScreen(
              docRef: Firestore.instance.collection('users').document(user.uid),
            );
          }));
            },
            ),
          ));
    }
    return ListView.builder(
      itemCount: snapshot.documents.length * 2 + 1,
      itemBuilder: (context, i) {
        if(i~/2 > snapshot.documents.length - 1) {
          return ListTile();
        }
        if (i.isOdd) {
          return Divider(height: 2, color: Colors.transparent,);
        } else {
          final index = i ~/ 2;
          return Dismissible(
            key: Key(snapshot.documents[index].documentID),
            onDismissed: (direction) {
              // Remove the item from the data source.
              Firestore.instance
                  .collection('users')
                  .document(user.uid)
                  .collection('stream')
                  .document(snapshot.documents[index].documentID)
                  .setData({'archived': true}, merge: true);
              setState(() {
                snapshot.documents.removeAt(index);
              });
              Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text("Compliment archived.")));
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
    final userName = mappedData['name'];
    return Card(
        color: Colors.white,
        //clipBehavior: Clip.none,
        elevation: 5,
        child: InkWell(
            splashColor: Colors.green.withAlpha(30),
            onTap: () {
              print('Card tapped.');
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Report Compliment',),
                    content: Container(
                      width: double.maxFinite,
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            title: Text('Choose a reason:', style: TextStyle( fontWeight: FontWeight.bold,),),
                          ),
                          Divider(),
                          ListTile(
                            title: Text("It's insulting"),
                            onTap: () {
                              Fluttertoast.showToast(msg: "We're sorry to hear about this!");
                            },
                          ),
                          Divider(),
                          ListTile(
                            title: Text("It's threatening"),
                            onTap: () {
                              Fluttertoast.showToast(msg: "We're sorry to hear about this!");
                            },
                          ),
                          Divider(),
                          ListTile(
                            title: Text("It's inappropriate"),
                            onTap: () {
                              Fluttertoast.showToast(msg: "We're sorry to hear about this!");
                            },
                          ),
                          Divider(),
                          ListTile(
                            title: Text("It's attacking"),
                            onTap: () {
                              Fluttertoast.showToast(msg: "We're sorry to hear about this!");
                            },
                          )
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Done',),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                      FlatButton(
                        child: Text('Cancel',),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      )
                    ],
                  );
                }
              );
            },
            child: Container(
                margin: EdgeInsets.all(16.0),
                width: 300,
                child: Column(children: [
                  Row(children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return UserInfoScreen(snap.data['user']);
                          }));
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                          radius: 30,
                          backgroundColor: Colors.transparent,
                        )),
                    Padding(padding: EdgeInsets.all(8.0)),
                    Text(
                      userName,
                      style: TextStyle(fontSize: min(240/userName.length, 24),),
                    ),
                    Spacer(),
                    GestureDetector(
                        onTap: () {
                          mappedData['user'].get().then(
                              (snapshot) {
                                var data = HashMap.of({
                                  'name': name,
                                  'pushID': snapshot.data['notificationID'],
                                  'imageUrl': user.photoUrl,
                                });
                                HttpsCallable sayThanks = CloudFunctions().getHttpsCallable(functionName: 'sayThanks');
                                sayThanks.call(data);
                              }
                          );
                        },
                        child: Text(
                          'Say Thanks!',
                          style:
                              TextStyle(color: Const.themeColor, fontSize: 18),
                        ))
                  ]),
                  Padding(padding: EdgeInsets.all(8.0)),
                  ListTile(
                    title: Text(
                      message,
                      style: TextStyle(fontSize: 18,),
                    ),
                    trailing: IconButton(
                      icon: Icon((!(snap.data['isInJournal'] ?? false))
                          ? Icons.bookmark_border
                          : Icons.bookmark),
                      onPressed: () {
                        if (!(snap.data['isInJournal'] ?? false)) {
                          snap.reference
                              .setData({'isInJournal': true}, merge: true);
                          Map data = snap.data;
                          data['docRef'] = snap.reference;
                          Firestore.instance
                              .collection('users')
                              .document(user.uid)
                              .collection('journal')
                              .document(snap.documentID)
                              .setData(data);
                        } else {
                          snap.reference
                              .setData({'isInJournal': false}, merge: true);
                          Firestore.instance
                              .collection('users')
                              .document(user.uid)
                              .collection('journal')
                              .document(snap.documentID)
                              .delete();
                        }
                        setState(() {});
                      },
                    ),
                  )
                ]))));
  }

  Drawer _makeDrawer() {
    return Drawer(
        child: ListView(children: [
      DrawerHeader(
        child: Row(children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return UserInfoScreen(Firestore.instance
                      .collection('users')
                      .document(user.uid));
                },
              ));
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
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return UserInfoScreen(Firestore.instance
                      .collection('users')
                      .document(user.uid));
                },
              ));
            },
            child: Text(name,
                style: TextStyle(
                  fontSize: 240 / max(name.length, 8),
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                )),
          ),
        ]),
        decoration: BoxDecoration(
          color: Const.themeColor,
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.home,
          color: Const.themeColor,
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
            color: Const.themeColor,
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
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return FriendScreen();
            }));
          }),
      Divider(),
      ListTile(
        leading: Icon(
          Icons.people_outline,
          color: Const.themeColor,
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
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return FriendRequestsScreen();
          }));
        },
      ),
      Divider(),
      ListTile(
        leading: Icon(
          Icons.book,
          color: Const.themeColor,
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
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return JournalScreen();
          }));
        },
      ),
      Divider(),
      ListTile(
        leading: Icon(
          Icons.archive,
          color: Const.themeColor,
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
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ArchivedScreen();
          }));
        },
      ),
      Divider(),
      ListTile(
        leading: Icon(
          Icons.settings,
          color: Const.themeColor,
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
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return SettingsScreen();
          }));
        },
      ),
      Divider(),
    ]));
  }
  AlertDialog getDailyObjectives(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        FlatButton(
          child: Text('See more',),
          onPressed: () async {
            Navigator.of(context).pop();
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) {
                      return EndlessSuggestions();
                    }
                )
            );
          }
        )
      ],
        title: Text('Ideas',),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance.collection('users').document(user.uid).get().asStream(),
                builder: (context, userData) {
                  if(userData.hasData && List.castFrom(userData.data.data['friends']).isNotEmpty) {
                    List friends = userData.data.data['friends'];
                    friends.shuffle();
                    DocumentReference chosenFriend = friends.first;
                    return StreamBuilder<DocumentSnapshot>(
                      stream: chosenFriend.get().asStream(),
                      builder: (context, snapshot) {
                        return ListTile(
                          trailing: Icon(
                            Icons.arrow_forward,
                            color: Const.themeColor,
                          ),
                          title: Text('Send a compliment to:\n${snapshot.hasData? snapshot.data.data['name']: 'someone'}!'),
                          onTap: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) {
                                      return NewComplimentScreen(docSnap: snapshot.hasData? snapshot.data : null);
                                    }
                                )
                            );
                          },
                        );
                      },
                    );
                  }
                  else {
                    return Divider(height: 0, color: Colors.transparent,);
                  }
                },
              ),
              Divider(),
              StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance.collection('prompts').document('selfPrompts').get().asStream(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    List promptList = snapshot.data.data['promptList'];
                    promptList.shuffle();
                    String prompt = promptList.first;
                    return ListTile(
                      trailing: Icon(
                        Icons.arrow_forward,
                        color: Const.themeColor,
                      ),
                      title: Text(prompt,),
                      onTap: () {
                        showDialog(context: context,
                          builder: (context) {
                            String temp = "";
                            return AlertDialog(
                              title: Text('New Journal Entry'),
                              content: Column(
                                children: <Widget>[
                                  Text(prompt),
                                  Divider(),
                                  TextField(
                                    decoration: InputDecoration.collapsed(hintText: 'Respond to the prompt here'),
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    onChanged: (value) {
                                      temp = value;
                                    },
                                  )
                                ],
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Submit'),
                                  onPressed: () {
                                    var docuRef = Firestore.instance.collection('users').document(user.uid).collection('journal').document(DateTime.now().millisecondsSinceEpoch.toString());
                                    docuRef.setData({ 'text' : temp });
                                    Navigator.of(context).pop(true);
                                  },
                                )
                              ],
                            );
                          },
                        );
                      },
                    );
                  }
                  else {
                    return Divider(height: 0, color: Colors.transparent,);
                  }
                },
              ),
              Divider(),
              StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance.collection('prompts').document('userPrompts').get().asStream(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    List promptList = snapshot.data.data['promptList'];
                    promptList.shuffle();
                    String prompt = promptList.first;
                    return ListTile(
                      trailing: Icon(
                        Icons.arrow_forward,
                        color: Const.themeColor,
                      ),
                      title: Text(prompt,),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              String temp = "";
                              return AlertDialog(
                                title: Text('New Compliment'),
                                content: Column(
                                  children: <Widget>[
                                    Text(prompt),
                                    Divider(),
                                    TextField(
                                      decoration: InputDecoration.collapsed(hintText: 'Type here'),
                                      keyboardType: TextInputType.multiline,
                                      textCapitalization: TextCapitalization.sentences,
                                      maxLines: null,
                                      onChanged: (value) {
                                        temp = value;
                                      },
                                    )
                                  ],
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text('Choose Recipient'),
                                    onPressed: () async {
                                      var data = HashMap.of({'comment': prompt + " " + temp});
                                      HttpsCallable readComment = CloudFunctions.instance.getHttpsCallable(functionName: 'readComment');
                                      showDialog<bool>(context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                                content: Container(
                                                  width: double.maxFinite,
                                                  child: FutureBuilder<HttpsCallableResult>(
                                                      future: readComment.call(data),
                                                      builder: (context, snapshot) {
                                                        if(!snapshot.hasData) return LinearProgressIndicator();
                                                        Map result = snapshot.data.data;
                                                        var problems = [];
                                                        for(int index = 0; index < result.length; index++) {
                                                          if(result.values.toList()[index]['spanScores'][0]['score']['value'] > 0.70) {
                                                            problems.add(result.keys.toList()[index]);
                                                          }
                                                        }
                                                        if(problems.length > 0) {
                                                          return ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount: problems.length,
                                                            itemBuilder: (context, i) {
                                                              return ListTile(
                                                                title: Text('Your comment has been flagged for ${problems[i]}.'),
                                                                subtitle: Text(['The compliment was not sent.',"Please consider what you're saying",'If you have nothing nice to say...', "Don't say anything at all", "Maybe you should reflect on what you said...", "Better luck next time"][i]),
                                                              );
                                                            },
                                                          );
                                                        }
                                                          Navigator.of(context).pop(true);
                                                          return Text('Your compliment is being sent...');
                                                      }
                                                  ),
                                                )
                                            );
                                          }
                                      ).then((isOk) { if(!(isOk??false)) return;});
                                      DocumentSnapshot snap = await Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) {
                                                return FriendSelector();
                                              }
                                          )
                                      );
                                      if(snap != null) {
                                        snap.reference.collection('stream').document(
                                            DateTime
                                                .now()
                                                .millisecondsSinceEpoch
                                                .toString()).setData(
                                            {
                                              'imageUrl': user.photoUrl,
                                              'user': Firestore.instance
                                                  .collection('users').document(
                                                  user.uid),
                                              'name': name,
                                              'text' : temp,
                                              'archived' : false,
                                            }
                                        );
                                        Fluttertoast.showToast(msg: 'Your compliment has been sent!');
                                      }
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      },
                    );
                  }
                  else {
                    return Divider(height: 0, color: Colors.transparent);
                  }
                },
              )
            ],
          ),
        )
    );
  }
}
