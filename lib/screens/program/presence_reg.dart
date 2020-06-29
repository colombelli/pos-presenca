import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:pg_check/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PresenceRegistration extends StatefulWidget {
  final User userInfo;
  PresenceRegistration({ Key key, this.userInfo}): super(key: key);

  @override
  _PresenceRegistrationState createState() => _PresenceRegistrationState();
}

class _PresenceRegistrationState extends State<PresenceRegistration> {
  
  GlobalKey globalKey = new GlobalKey();

  final CollectionReference programsCollection = Firestore.instance.collection('programs');
  Future<void> updateProgramHash() async {
    return await programsCollection.document(widget.userInfo.uid).setData({
      'name': widget.userInfo.name,
      'key': _dataString,
      'key2': _key2
    });
  }

  Timer timer;
  Timer timer2;
  var uuid = Uuid();

  String _dataString;
  String _key2;

  changeQRcode() {
    String newEncodedString = uuid.v4();
    setState(() {
      _dataString = newEncodedString;
    });
    updateProgramHash();

    new Timer(const Duration(seconds: 10), () {
      setState(() {
        _key2 = _dataString;
      });

      updateProgramHash();
    });
  }

  


  @override
  void initState() {
    super.initState();
    String newEncodedString = uuid.v4();
    _dataString = newEncodedString;
    _key2 = newEncodedString;
    updateProgramHash();

    timer = Timer.periodic(Duration(seconds: 60), (Timer t) => changeQRcode());
  }

  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.supervisor_account),
        title: Text(translation('presence_registration_title')),
        backgroundColor: Colors.orange[700],
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
//            Expanded(
//              child:  Center(
//                child: Text(_dataString)
//              ),
//            ),
          ],
        )
      )
    );
  }
}