import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/shared/constants.dart';
import 'package:pg_check/shared/loading.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}


class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  String error = '';
  
  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return loading ? Loading() : Scaffold (
      backgroundColor: Colors.orange[700],
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        elevation: 0.0,
        title: Text(translation('sign_in_title')),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text(translation('sign_up_button')),
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
                cursorColor: Colors.deepOrange,
                decoration: textInputDecoration.copyWith(
                  hintText: translation("email_hint")
                ),
                validator: (value) => value.isEmpty ? translation('email_empty') : null,
                onChanged: (value){
                  setState(() => email = value);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                cursorColor: Colors.deepOrange,
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
                color: Colors.deepOrange ,//orange[400],
                splashColor: Colors.grey,
                elevation: 10.0,
                child: Text(
                  translation('sign_in_text'), 
                  style: TextStyle(color: Colors.white),
                  ),
                onPressed: () async {
                  if(_formKey.currentState.validate()){
                    
                    // activates loading widget
                    setState(() => loading=true);

                    dynamic result = await _auth.signIn(email, password);
                    if(result == null){
                      setState(() {
                        error = translation('invalid_credentials');
                        loading = false;
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