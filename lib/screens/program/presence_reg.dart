import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class PresenceRegistration extends StatefulWidget {
  @override
  _PresenceRegistrationState createState() => _PresenceRegistrationState();
}

class _PresenceRegistrationState extends State<PresenceRegistration> {
  
  GlobalKey globalKey = new GlobalKey();
  
  Timer timer;
  var uuid = Uuid();

  String _dataString;

  changeQRcode() {
    String newEncodedString = uuid.v4();
    setState(() {
      _dataString = newEncodedString;
    });

  }

  @override
  void initState() {
    super.initState();
    _dataString = uuid.v4();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => changeQRcode());
  }

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