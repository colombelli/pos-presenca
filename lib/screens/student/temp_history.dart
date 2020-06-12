import 'package:flutter/material.dart';
import 'package:pg_check/screens/student/student_drawer.dart';
import 'package:pg_check/models/user.dart';


class StudentHistoryTemp extends StatelessWidget {
  StudentHistoryTemp(this.userInfo);
  final User userInfo;


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.blue[50],
      endDrawer: StudentDrawer(userInfo),
      appBar: AppBar(
        title: Text('PAGINA TEMPORARIA TESTANDO OUTRA SCREEN'),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,

        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState.openEndDrawer()
          )
        ]
      ),
      body: Text('PAGINA TEMPORARIA TESTANDO OUTRA SCREEN'),
    );
  }
}