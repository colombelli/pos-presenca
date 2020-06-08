import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Professor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: new AppBar(
        title: new Text("Demo"),
      ),

      body: StreamBuilder(
        stream: Firestore.instance.collection('students').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text('Loading data. Please wait.');
          return Column(
            children: <Widget>[
              Text(snapshot.data.documents[0]['name']),
              Text(snapshot.data.documents[0]['professor'])
            ],
          );
        },
      )
    );
  }
}