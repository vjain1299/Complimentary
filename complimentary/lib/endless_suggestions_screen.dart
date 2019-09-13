import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/const.dart';
import 'package:complimentary/friend_selector.dart';
import 'package:complimentary/new_compliment_screen.dart';
import 'package:complimentary/sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EndlessSuggestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text('Suggestions'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: EndlessSuggestionList(),
    );
  }
}
class EndlessSuggestionList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EndlessSuggestionListState();
  }
}
class EndlessSuggestionListState extends State<EndlessSuggestionList> {
  List userPrompts = List();
  List selfPrompts = List();
  List friends = List();
  @override
  void initState() {
    getFriends();
    getSelfPrompts();
    getUserPrompts();
    super.initState();
  }
  Future getFriends() async {
    DocumentSnapshot userDoc = await Firestore.instance.collection('users').document(user.uid).get();
    friends = [];
    List.castFrom(userDoc.data['friends']??List()).forEach((ref) async {
      DocumentSnapshot docSnap = await ref.get();
      friends.add(docSnap);
    });
    setState(() {
      friends = friends;
    });
  }
  Future getSelfPrompts() async {
    DocumentSnapshot selfPromptDoc = await Firestore.instance.collection('prompts').document('selfPrompts').get();
    selfPrompts = selfPromptDoc.data['promptList']??List();
    setState(() {
      selfPrompts = selfPrompts;
    });
  }
  Future getUserPrompts() async {
    DocumentSnapshot userPromptDoc = await Firestore.instance.collection('prompts').document('userPrompts').get();
    userPrompts = userPromptDoc.data['promptList']??List();
    setState(() {
      userPrompts = userPrompts;
    });
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (context, index) {
          if(index.isOdd) return Divider();
          else return _suggestionGroupItem();
        }
    );
  }
  Widget _suggestionGroupItem() {
    DocumentSnapshot randomFriend = friends.isNotEmpty? (friends..shuffle()).first : null;
    String randomSelfPrompt = selfPrompts.isNotEmpty?(selfPrompts..shuffle()).first : 'Loading...';
    String randomUserPrompt = userPrompts.isNotEmpty ? (userPrompts..shuffle()).first : 'Loading...';
    return Column(
      children: <Widget>[
        randomFriend == null?
            Container(width: 0.0, height: 0.0,)
        : ListTile(
          trailing: Icon(
            Icons.arrow_forward,
            color: themeColor,
          ),
          title: Text('Send a compliment to: ${randomFriend == null? 'Someone' : randomFriend.data['name']??'Someone'}!'),
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) {
                      return NewComplimentScreen(docSnap : randomFriend);
                    },
                )
              );
            },
        ),
        randomFriend == null? Container(height: 0.0, width: 0.0,) : Divider(),
        ListTile(
          trailing: Icon(
            Icons.arrow_forward,
            color: themeColor,
          ),
          title: Text(randomSelfPrompt),
          onTap: () {
            showDialog(context: context,
              builder: (context) {
              String temp = "";
              return AlertDialog(
                title: Text('New Journal Entry'),
                content: Column(
                  children: <Widget>[
                    Text(randomSelfPrompt),
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
                ],);
              },
            );
          },
        ),
        Divider(),
        ListTile(
          trailing: Icon(
            Icons.arrow_forward,
            color: themeColor,
          ),
          title: Text(randomUserPrompt),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  String temp = "";
                  return AlertDialog(
                    title: Text('New Compliment'),
                    content: Column(
                      children: <Widget>[
                        Text(randomUserPrompt),
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
        ),
      ],
    );
  }
}