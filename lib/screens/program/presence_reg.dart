import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class PresenceRegistration extends StatefulWidget {
  @override
  _PresenceRegistrationState createState() => _PresenceRegistrationState();
}

class _PresenceRegistrationState extends State<PresenceRegistration> {
  
  GlobalKey globalKey = new GlobalKey();
  String _dataString = "Hello from this QR";
  

  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.supervisor_account),
        title: Text(translation('presence_registration_title')),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
      ),
      body: Container(
        color: const Color(0xFFFFFFFF),
        child:  Column(
          children: <Widget>[
            Expanded(
              child:  Center(
                child: QrImage(
                    data: _dataString,
                ),
              ),
            ),
          ],
        )
      )
    );
  }
}