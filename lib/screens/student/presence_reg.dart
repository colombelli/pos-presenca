import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:pg_check/models/user.dart';
import 'package:pg_check/shared/loading.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class StudentPresenceRegistration extends StatefulWidget {

  final User userInfo;
  StudentPresenceRegistration({ Key key, this.userInfo}): super(key: key);

  @override
  _StudentPresenceRegistrationState createState() => _StudentPresenceRegistrationState();
}

class _StudentPresenceRegistrationState extends State<StudentPresenceRegistration> {
  
  final CollectionReference programsCollection = Firestore.instance.collection('users');
  Future<void> updateUserPIN() async {
    return await programsCollection.document(widget.userInfo.uid).setData({
      'name': widget.userInfo.name,
      'program': widget.userInfo.program,
      'type': widget.userInfo.type,
      'pin1': _pin1,
      'pin2': _pin2
    });
  }

  String generatePIN() {
    var rand = new Random();
    var pin =  new List.generate(6, (_) => rand.nextInt(10));
    
    String strPIN = "";
    pin.forEach((element) {strPIN = strPIN + element.toString();});

    return strPIN;
  }

  Timer timer;

  String _pin1;
  String _pin2;



  void changePINcode() {
    String newPIN = generatePIN();
    setState(() {
      _pin1 = newPIN;
    });
    updateUserPIN();

    new Timer(const Duration(seconds: 10), () {
      setState(() {
        _pin2 = _pin1;
      });

      updateUserPIN();
    });
  }

  


  @override
  void initState() {
    super.initState();

    var newPIN;
    newPIN = generatePIN();

    _pin1 = newPIN;
    _pin2 = newPIN;
    updateUserPIN();

    timer = Timer.periodic(Duration(seconds: 60), (Timer t) => changePINcode());
  }


  @override
  Widget build(BuildContext context) {
    
    return Column(
            children: <Widget>[
              Container(
                  height: 40
                ),

              Center(
                  child: Container(
                  height: 100,
                  width: 300,
                  child:  Card(
                    color: Colors.white,
                      child:
                        Container( 
                        height: 50,
                        width: 50,
                        child: Center(
                          child: Text('PIN', style: TextStyle(fontSize: 50, color: Colors.deepOrange),)
                          )
                        )
                      )
                    )
                ),

                Container(
                  height: 10
                ),

                Center(
                  child: Container(
                  height: 100,
                  width: 300,
                  child:
                  Card(
                  color: Colors.white,
                  child:
                  Container( 
                    height: 50,
                    width: 50,
                    child: Center(
                      child: Text(_pin1, style: TextStyle(fontSize: 50, color: Colors.deepOrange),)
                    )
                  )
                  )
                  ),
                ),
            ],
          );
       
  }
}




