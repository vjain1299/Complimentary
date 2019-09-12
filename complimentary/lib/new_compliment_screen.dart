import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/friend_screen.dart';
import 'package:complimentary/friend_selector.dart';
import 'package:complimentary/sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

String prefix = "";
class NewComplimentScreen extends StatefulWidget {
  DocumentReference docRef;
  DocumentSnapshot docSnap;
  NewComplimentScreen({this.docSnap, this.docRef} );
  @override
  State<StatefulWidget> createState() {
    return NewComplimentState(docSnap, docRef);
  }
}
class NewComplimentState extends State<NewComplimentScreen> {
  NewComplimentState(DocumentSnapshot docuSnap, DocumentReference docuRef) {
    if(docuSnap == null && docuRef == null) return;
    docRef = (docuRef??docuSnap.reference)
        .collection('stream')
        .document(DateTime.now().millisecondsSinceEpoch.toString());
    docSnap = docuSnap;
  }
  DocumentReference docRef;
  DocumentSnapshot docSnap;
  var globalKey = GlobalKey();
  var compliment;
  var userName;
  var imageUrl;
  var selectedItem;
  var prefixPicker;
  @override void initState() {
    super.initState();
    compliment = "";
    userName = docSnap != null? docSnap.data['name'] : 'Yourself';
    imageUrl = docSnap != null? docSnap.data['imageUrl'] : user.photoUrl;
    prefixPicker = PrefixPicker();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('New Compliment'),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              if(docRef == null) {
                Fluttertoast.showToast(
                  msg: 'Please specify a recipient',
                  toastLength: Toast.LENGTH_LONG,
                );
                onTapped();
              }
              else if(compliment.toString() == "") {
                Fluttertoast.showToast(
                  msg: 'Please enter a compliment',
                  toastLength: Toast.LENGTH_LONG,
                );
                return;
              }
              docRef.setData({
                'user':
                Firestore.instance.collection('users').document(user.uid),
                'text': prefix + " " + (prefix == ""? compliment : compliment.toString().substring(0,1).toLowerCase() + compliment.toString().substring(1)),
                'archived': false,
                'imageUrl': user.photoUrl,
                'name': name,
                'createdAt': docRef.documentID
              });
              Navigator.pop(context, false);
            },
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.check,
              size: 20,
              color: Colors.white,
            )),
        body: ListView(children: [
          Divider(color: Colors.white, height: 4),
          docRef == null?
          ListTile(
            title: Text('Choose a recipient', textAlign: TextAlign.center,),
            onTap: onTapped,
          ) :
          ListTile(
            contentPadding: EdgeInsets.all(16.0),
            title: Text(userName),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.transparent,
              radius: 30,
            ),
            onTap: onTapped,
          ),
          Divider(),
          ListTile(
            contentPadding: EdgeInsets.all(0.0),
            title: prefixPicker,
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration.collapsed(hintText: 'Write your compliment here'),
              maxLines: null,
              onChanged: (value) {
                compliment = value;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ])
    );
  }
  Future onTapped() async{
    DocumentSnapshot snap = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return FriendSelector();
        }
      )
    );
    if(snap == null) return;
    setState(() {
      docSnap = snap;
      docRef = snap.reference.collection('stream').document(DateTime.now().millisecondsSinceEpoch.toString());
      userName = docSnap != null? docSnap.data['name'] : 'Yourself';
      imageUrl = docSnap != null? docSnap.data['imageUrl'] : user.photoUrl;
    });
  }
}
class PrefixPicker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PrefixPickerState();
}

class PrefixPickerState extends State<PrefixPicker> {
  String currentItem;
  String optionSelected;
  bool expanded;
  final prefixList = ['My favorite thing about you is ', "You've always been talented at", ''];
  OverlayEntry _overlayEntry;
  @override
  void initState() {
    currentItem = "";
    optionSelected = "";
    expanded = false;
    super.initState();
  }
  OverlayEntry _createOverlayEntry() {

    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
        builder: (context) => Positioned(
          left: offset.dx,
          top: offset.dy + size.height + 5.0,
          width: size.width,
          child: Material(
            elevation: 2.0,
            child: StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance.collection('prompts').document('prefices').get().asStream(),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  var dataMap = snapshot.data.data;
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: dataMap.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(dataMap.keys.toList()[index]),
                        onTap: () {
                          setState(() {
                            currentItem = dataMap.values.toList()[index];
                            prefix = currentItem;
                            optionSelected = dataMap.keys.toList()[index];
                            expanded = false;
                            try {
                              this._overlayEntry.remove();
                            }
                            catch(ex) {
                            }
                          });
                        },
                      );
                    },
                  );
                }
                else {
                  return LinearProgressIndicator();
                }
              }
            )
          ),
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: optionSelected == ''? Text('Choose a prompt', textAlign: TextAlign.center,) : Text(currentItem + '...'),
      onTap: () {
        setState(() {
          if(expanded) return;
          this._overlayEntry = this._createOverlayEntry();
          Overlay.of(context).insert(this._overlayEntry);
          expanded = true;
        });
      }
    );
  }
}
