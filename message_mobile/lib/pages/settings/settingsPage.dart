import 'package:flutter/material.dart';
import 'package:message_mobile/models/chatmodel.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () {},
            leading: CircleAvatar(
              backgroundImage: AssetImage("assets/avatar.jpg"),
            ),
            title: Text("Upload Profile Image"),
          ),
          ListTile(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Change User Name"),
                  content: TextField(
                    decoration: InputDecoration(labelText: "User Name"),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Ok"),
                    ),
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              );
            },
            title: Text(testOwner.userName),
            trailing: Icon(Icons.edit),
          ),
          SwitchListTile(
            value: false,
            title: Text("Save Data To Local"),
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
