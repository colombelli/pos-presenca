import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';

class Home extends StatelessWidget {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    // To-do: define it in wrapper and make it accessible to all child widgets
    final translation = (String s) => AppLocalizations.of(context).translate(s);
    
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(translation('home_title')),
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
    );
  }
}