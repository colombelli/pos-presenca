import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}


class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold (
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        title: Text(AppLocalizations.of(context).translate('sign_in_title')),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
        child: RaisedButton(
          child: Text(AppLocalizations.of(context).translate('sign_in_text')),
          onPressed: () async {
            
          },
          ),
      ),
    );
  }
}