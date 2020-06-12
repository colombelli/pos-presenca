import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/shared/loading.dart';
import 'package:pg_check/screens/student/student_drawer.dart';


class StudentHome extends StatefulWidget {

  final User userInfo;
  const StudentHome ({ Key key, this.userInfo}): super(key: key);

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    

    final translation = (String s) => AppLocalizations.of(context).translate(s);


    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.blue[50],
      endDrawer: StudentDrawer(widget.userInfo),
      appBar: AppBar(
        title: Text(translation('home_title')),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,

        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState.openEndDrawer()
          )
        ]
      ),
      body: Text("a"),
    );
  }
}
