
import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Program extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: new AppBar(
        leading: Icon(Icons.account_balance),
        title: new Text("PPGC Menu"),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            onPressed: () async {
              await _auth.signOut();  // and does nothing else because there's a streaming 
                                      // already hearing the value of User and when it is null
                                      // it renders the Authenticate screen instead of Home
            },
            label: Text(translation('logout_button')),
          )
        ]
      ),
      body: MenuList(),
    );
  }
}

//Menu:
//- justification
//- process weekly
//- view absences

class MenuList extends StatefulWidget {
  @override
  _MenuListState createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
      ],
    );
  }
}
