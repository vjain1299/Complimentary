import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complimentary/sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                name,
              style: TextStyle(
                color: Colors.grey
              ),
            ),
            onTap: () {
              var temp = "";
                showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      title: Text('Display Name'),
                      content: TextField(
                        onChanged: (value) {
                          temp = value;
                        },
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Set'),
                          onPressed: () {
                            Firestore.instance.collection('users').document(user.uid).setData({'nickname': temp}, merge : true);
                            name = temp;
                            Navigator.of(context).pop(false);
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
          //Put in other settings here
        ],
      ),
    );
  }
}