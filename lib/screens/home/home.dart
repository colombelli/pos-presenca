import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();

  LocalAuthentication bioauth = LocalAuthentication();
  Future<void> _checkBiometrics() async {
     bool canCheckBiometrics;
    try {
      canCheckBiometrics = await bioauth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    }); 
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await bioauth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    }); 
  } 

  Future<void> _bioauthenticate() async {
    bool bioauthenticated = false;

    try {
      bioauthenticated = await bioauth.authenticateWithBiometrics(
        localizedReason: "Scan your fingerprint to authenticate",
        useErrorDialogs: true,
        stickyAuth: false,

      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _authorized = bioauthenticated ? "Authorized" : "Not authorized";
    });

  }

  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = "Not authorized"; //temporary to proof-of-concept
  

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
    body: Container(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(translation('can_check_biometrics') + "$_canCheckBiometrics\n"),
            RaisedButton(
              child: Text(translation('check_biometrics')),
              onPressed: _checkBiometrics),
            Text(translation('available_biometrics') + "$_availableBiometrics\n"),
            RaisedButton(
              child: Text(translation('get_available_biometrics')),
              onPressed: _getAvailableBiometrics),
            Text(translation('current_state') + "$_authorized\n"),
            RaisedButton(
              child: Text(translation('bioauthenticate')),
              onPressed: _bioauthenticate),
          ],
          )
      ),
    ),
    );
  }
}

