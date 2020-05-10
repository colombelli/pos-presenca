import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/shared/constants.dart';
import 'package:pg_check/shared/loading.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  Register({ this.toggleView });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {


  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;
  

  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return loading ? Loading() : Scaffold (
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        title: Text(translation('sign_up_title')),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text(translation('sign_in_text')),
            onPressed: () {
              widget.toggleView();
            },  
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(
                  hintText: translation("email_hint"),
                ),
                validator: (value) => value.isEmpty ? translation('email_empty') : null,
                onChanged: (value){
                  setState(() => email = value);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(
                  hintText: translation("password_hint")
                ),
                validator: (value) => value.length < 6 ? translation('short_pass') : null,
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
                  if(_formKey.currentState.validate()){
                    setState(() => loading = true);

                    dynamic result = await _auth.registerEmailPassword(email, password);
                    if(result == null){
                      setState(() {
                        error = translation('invalid_email_error');
                        setState(() => loading = false);
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 20.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0)
                )
            ],
          ),
          ),
        ),
      );
  }
}