import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'dart:async';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pg_check/shared/loading.dart';
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


  bool _loading = false;
  String _userReg = '';

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Colors.white),
      borderRadius: BorderRadius.circular(15),
    );
  }


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);
    

    Widget continueButton = FlatButton(
        child: Text("Continuar"),
        textColor: Colors.orange[700],
        onPressed:  () {
          _pinPutController.text = '';
          Navigator.pop(context);
        },
        );
 

        Widget cancelButton = FlatButton(
        child: Text("Cancelar"),
        textColor: Colors.orange[700],
        onPressed:  () {
          _pinPutController.text = '';
          Navigator.pop(context);
        },
        );

        Widget againButton = FlatButton(
        child: Text("Tentar Novamente"),
        textColor: Colors.orange[700],
        onPressed:  () {
          Navigator.pop(context);
        },
        );

        AlertDialog errorReg = AlertDialog(
          title: Text("Erro"),
          content: Text("Não foi possível registrar a presença. Por favor, tente novamente."),
          actions: [
            cancelButton,
            againButton
          ],
        );


    final CollectionReference usersCollection = Firestore.instance.collection('users');
    Future<List<dynamic>> getPossiblePINs() async {
      
      var possiblePINs = [];
      await usersCollection.getDocuments().then(
        (snap) => {
            snap.documents.forEach((doc) { 
              dynamic user = doc.data;
              if (user['pin1'] != null) {
                possiblePINs.add({'name': user['name'], 'pin1': user['pin1'], 'pin2': user['pin2']});
              }
          })
        }
        
      );     
    return possiblePINs;
    }

    Future<List<dynamic>> registerPresence(String pin) async{
      
      _loading = true;
      var matchAnswer = [false, ''];

      await getPossiblePINs().then(
        (possiblePINs) {
          
          for (var user in possiblePINs) {

            if (pin == user['pin1'] || pin == user['pin2']){
              _loading = false;
              _pinPutController.text = '';
            
              matchAnswer = [true, user['name']];
            }
          }
        });

      _loading = false;
      return matchAnswer;
    }


    return _loading ? Loading() : Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.supervisor_account),
        title: Text(translation('presence_registration_title')),
        backgroundColor: Colors.orange[700],
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.orange[700],
        child:  Column(
          
          children: <Widget>[
            SizedBox(
              height: 20
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
                        width: 70,
                        child: Center(
                          child: Text('Digite seu PIN', style: TextStyle(fontSize: 40, color: Colors.deepOrange),)
                          )
                        )
                      )
                    )
                ),

            SizedBox(height:20),
            Center(
              child: Container(
                    width: 300,
                    child: PinPut(
                        fieldsCount: 6,
                        onSubmit: (String pin) => print(pin),//_showSnackBar(pin, context),
                        focusNode: _pinPutFocusNode,
                        controller: _pinPutController,
                        submittedFieldDecoration: _pinPutDecoration.copyWith(
                            borderRadius: BorderRadius.circular(20)),
                        selectedFieldDecoration: _pinPutDecoration,
                        followingFieldDecoration: _pinPutDecoration.copyWith(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ),
            ),

              SizedBox(
              height: 20
            ),

            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              
              children: <Widget>[

              Container( 
                    height: 60,
                    width: 120,
                    child:
                        RaisedButton(
                          color: Colors.deepOrange,
                          textColor: Colors.white,
                          splashColor: Colors.deepOrange,
                          onPressed: () async {
                              var matchResult;
                              await registerPresence(_pinPutController.text).then((value) => matchResult = value);
                              
                              if (matchResult[0]){
                                showDialog(context: context, builder: (context)=>AlertDialog(
                                    title: Text("Obrigado, "+matchResult[1]),
                                    content: Text("Sua presença foi registrada com sucesso!"),
                                    actions: [
                                      continueButton
                                    ],
                                  ));
                              } else {
                                showDialog(context: context, builder: (context)=>errorReg);
                              }
                            },
                          child: const Text('Registrar', style: TextStyle(fontSize: 17),)
                    ),
                  ),
                SizedBox(width: 10,),
                Container( 
                    height: 60,
                    width: 120,
                    child:
                        RaisedButton(
                          color: Colors.deepOrange,
                          textColor: Colors.white,
                          splashColor: Colors.deepOrange,
                          onPressed: () => {
                              _pinPutController.text = '',
                            },
                          child: const Text('Limpar', style: TextStyle(fontSize: 17),)
                    ),
                  )
            ],)
            

          ],
        )
      )
    );
  }

}