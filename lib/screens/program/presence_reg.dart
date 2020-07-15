import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import 'package:pinput/pin_put/pin_put.dart';
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


  String _dataString;
  String _key2;

  TextEditingController textEditingController = TextEditingController();

  StreamController<ErrorAnimationType> errorController;

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
    errorController = StreamController<ErrorAnimationType>();
  }

  @override
  void dispose() {
    errorController.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);
    

    Widget continueButton = FlatButton(
        child: Text("Continuar"),
        textColor: Colors.orange[700],
        onPressed:  () {
          Navigator.popAndPushNamed(context, '/');
        },
        );

        AlertDialog success = AlertDialog(
          title: Text("Registrado"),
          content: Text("Presença registrada com sucesso."),
          actions: [
            continueButton
          ],
        );     

        Widget cancelButton = FlatButton(
        child: Text("Cancelar"),
        textColor: Colors.orange[700],
        onPressed:  () {
          Navigator.popAndPushNamed(context, '/');
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


    return Scaffold(
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
                          onPressed: () => {
                              _pinPutController.text = '',
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