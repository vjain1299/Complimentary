import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/const.dart' as prefix0;
import 'package:complimentary/login.dart';
import 'package:complimentary/sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:complimentary/const.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}
class SettingsState extends State<SettingsScreen> {
  var myName = name;
  var affirm = affirmations;
  Color tempColor;
  @override
  void initState() {
    tempColor = themeColor;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Color tempColor = themeColor;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text('Settings'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back
          ),
          onPressed: ()  { Navigator.pop(context, true); },
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Username'),
            trailing: Text(
                myName,
              style: TextStyle(
                color: Colors.grey
              ),
            ),
            onTap: () {
                showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      title: Text('Update your username'),
                      content: TextField(
                        controller: TextEditingController(text: myName),
                        onChanged: (value) {
                          myName = value;
                        },
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Set'),
                          onPressed: () {
                            Firestore.instance.collection('users').where('name', isEqualTo: myName).getDocuments().then((snap) {
                              if(snap.documents.length == 0) {
                                Firestore.instance.collection('users').document(user.uid).setData({'name': myName}, merge : true);
                                name = myName;
                                Navigator.of(context).pop(false);
                                setState(() {
                                  myName = name;
                                });
                              }
                              else {
                                Fluttertoast.showToast(msg: 'That username is already taken.');
                              }
                            });
                          },
                        ),
                        FlatButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        )
                      ],
                    );
                  }
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Theme Color'),
            trailing: Icon(
              Icons.brightness_1,
              color: themeColor,
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Choose a color:'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: prefix0.themeColor,
                        enableLabel: true,
                        pickerAreaHeightPercent: 0.8,
                        onColorChanged: (color) {
                          tempColor = color;
                        },
                      )
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      FlatButton(
                        child: Text('Apply'),
                        onPressed: () {
                          themeColor = tempColor;
                          Firestore.instance.collection('users').document(user.uid).setData({'preferredColor' : themeColor.value}, merge: true);
                          Navigator.of(context).pop(false);
                          setState(() {
                            tempColor = themeColor;
                          });
                        },
                      )
                    ],
                  );
                }
              );
            },
          ),
          Divider(),
//          ListTile(
//            title: Text('Text Color'),
//            trailing: Icon(
//              Icons.brightness_1,
//              color: prefix0.textColor,
//            ),
//            onTap: () {
//              showDialog(
//                  context: context,
//                  builder: (context) {
//                    return AlertDialog(
//                      title: Text('Choose a color:'),
//                      content: SingleChildScrollView(
//                          child: ColorPicker(
//                            pickerColor: prefix0.textColor,
//                            enableLabel: true,
//                            pickerAreaHeightPercent: 0.8,
//                            onColorChanged: (color) {
//                              tempColor = color;
//                            },
//                          )
//                      ),
//                      actions: <Widget>[
//                        FlatButton(
//                          child: Text('Cancel'),
//                          onPressed: () {
//                            Navigator.of(context).pop(false);
//                          },
//                        ),
//                        FlatButton(
//                          child: Text('Apply'),
//                          onPressed: () {
//                            prefix0.textColor = tempColor;
//                            Firestore.instance.collection('users').document(user.uid).setData({'preferredTextColor' : prefix0.textColor.value}, merge: true);
//                            Navigator.of(context).pop(false);
//                            setState(() {
//                              tempColor = textColor;
//                            });
//                          },
//                        )
//                      ],
//                    );
//                  }
//              );
//            },
//          ),
//          Divider(),
//          ListTile(
//            title: Text('Card Color'),
//            trailing: Icon(
//              Icons.brightness_1,
//              color: prefix0.cardColor,
//            ),
//            onTap: () {
//              showDialog(
//                  context: context,
//                  builder: (context) {
//                    return AlertDialog(
//                      title: Text('Choose a color:'),
//                      content: SingleChildScrollView(
//                          child: ColorPicker(
//                            pickerColor: prefix0.cardColor,
//                            enableLabel: true,
//                            pickerAreaHeightPercent: 0.8,
//                            onColorChanged: (color) {
//                              tempColor = color;
//                            },
//                          )
//                      ),
//                      actions: <Widget>[
//                        FlatButton(
//                          child: Text('Cancel'),
//                          onPressed: () {
//                            Navigator.of(context).pop(false);
//                          },
//                        ),
//                        FlatButton(
//                          child: Text('Apply'),
//                          onPressed: () {
//                            prefix0.cardColor = tempColor;
//                            Firestore.instance.collection('users').document(user.uid).setData({'preferredCardColor' : prefix0.cardColor.value}, merge: true);
//                            Navigator.of(context).pop(false);
//                            setState(() {
//                              tempColor = prefix0.cardColor;
//                            });
//                          },
//                        )
//                      ],
//                    );
//                  }
//              );
//            },
//          ),
//          Divider(),
//          ListTile(
//            title: Text('Background Color'),
//            trailing: Icon(
//              Icons.brightness_1,
//              color: prefix0.backgroundColor,
//            ),
//            onTap: () {
//              showDialog(
//                  context: context,
//                  builder: (context) {
//                    return AlertDialog(
//                      title: Text('Choose a color:'),
//                      content: SingleChildScrollView(
//                          child: ColorPicker(
//                            pickerColor: prefix0.backgroundColor,
//                            enableLabel: true,
//                            pickerAreaHeightPercent: 0.8,
//                            onColorChanged: (color) {
//                              tempColor = color;
//                            },
//                          )
//                      ),
//                      actions: <Widget>[
//                        FlatButton(
//                          child: Text('Cancel'),
//                          onPressed: () {
//                            Navigator.of(context).pop(false);
//                          },
//                        ),
//                        FlatButton(
//                          child: Text('Apply'),
//                          onPressed: () {
//                            prefix0.backgroundColor = tempColor;
//                            Firestore.instance.collection('users').document(user.uid).setData({'preferredBackgroundColor' : prefix0.backgroundColor.value}, merge: true);
//                            Navigator.of(context).pop(false);
//                            setState(() {
//                              tempColor = prefix0.backgroundColor;
//                            });
//                          },
//                        )
//                      ],
//                    );
//                  }
//              );
//            },
//          ),
          ListTile(
            title: Text('Affirmations'),
            subtitle: Text('Do you want to be greeted by an affirmation every time you open the app?'),
            onTap: () {
              Firestore.instance.collection('users').document(user.uid).updateData({'affirmations' : !affirm});
              setState(() {
                affirm = !affirm;
              });
            },
            trailing: Icon(
              affirm? Icons.check_box : Icons.check_box_outline_blank
            ),
          ),
          Divider(),
          ListTile(
            trailing: Icon(Icons.info_outline),
            title: Text('About'),
            onTap: () {
              showDialog(context: context,
                builder: (context) {
                  return AboutDialog(
                    applicationName: 'Complimentary',
                    applicationVersion: 'v0.0.1',
                    applicationIcon: Image(image: AssetImage('assets/closeGap.png'), width: 40, height: 40,),
                    applicationLegalese: 'Creator: Vikas Jain',
                  );
                }
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text('Sign Out'),
            onTap: () {
              signOutGoogle();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }), ModalRoute.withName('/'));
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}