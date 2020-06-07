import 'package:flutter/material.dart';
import 'package:pg_check/screens/authenticate/register.dart';
import 'package:pg_check/screens/authenticate/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:pg_check/services/database.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;
  void toggleView () {
    setState(() {
        showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    if (showSignIn) {
      return SignIn(toggleView: toggleView);
    } else {
      return StreamProvider<QuerySnapshot>.value(
        value: DatabaseService().programs,
        child: Register(toggleView: toggleView));
    }

  }
}