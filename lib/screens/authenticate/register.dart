import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {


  final AuthService _auth = AuthService();

  // text field state
  String email = '';
  String password = '';
  

  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold (
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        title: Text(translation('sign_up_title')),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
        child: Form(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                onChanged: (value){
                  setState(() => email = value);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                obscureText: true,
                onChanged: (value) {
                  setState(() => password = value);
                }
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                color: Colors.indigo,
                child: Text(
                  translation('sign_up_text'), 
                  style: TextStyle(color: Colors.white)
                  ),
                onPressed: () async {
                  
                },
              )
            ],
          ),
          ),
        ),
      );
  }
}