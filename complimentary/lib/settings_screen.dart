import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:complimentary/const.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsState();
  }
}
class SettingsState extends State<SettingsScreen> {
  var myName = name;
  @override
  Widget build(BuildContext context) {
    Color tempColor = themeColor;
    return Scaffold(
      appBar: AppBar(
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
            title: Text('Display Name'),
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
                      title: Text('Display Name'),
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
                            Firestore.instance.collection('users').document(user.uid).setData({'nickname': myName}, merge : true);
                            name = myName;
                            Navigator.of(context).pop(false);
                            setState(() {
                              myName = name;
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
                        pickerColor: tempColor,
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
                          Navigator.of(context).pop(false);
                          Scaffold
                              .of(context)
                              .showSnackBar(
                              SnackBar(content: Text("You must restart the app for changes to take effect.")));
                          setState(() {});
                        },
                      )
                    ],
                  );
                }
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}