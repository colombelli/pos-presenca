import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:pg_check/models/user.dart';

class StudentPresenceRegistration extends StatefulWidget {

  final User userInfo;
  StudentPresenceRegistration({ Key key, this.userInfo}): super(key: key);

  @override
  _StudentPresenceRegistrationState createState() => _StudentPresenceRegistrationState();
}

class _StudentPresenceRegistrationState extends State<StudentPresenceRegistration> {
  
  String _barcodeString = "";
  
  @override
  initState() {
    super.initState();
  } 

  @override
  Widget build(BuildContext context) {
    
    Widget continueButton = FlatButton(
        child: Text("Continuar"),
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
        onPressed:  () {
          Navigator.popAndPushNamed(context, '/');
        },
        );

        Widget againButton = FlatButton(
        child: Text("Tentar Novamente"),
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
  
    void validateReg(String codeReaded, String userId) async {
      
      var baseUrl = 'https://us-central1-pg-check-68d1b.cloudfunctions.net/presenceRegistration';
      var reqUrl = baseUrl + "?regCode=" + codeReaded + "&userID=" + userId; 

      var response = await http.get(reqUrl);
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);

        if (jsonResponse){
          print('reg confirmed');
          return showDialog(
                  context: context,
                  builder: (context) => success
                );
        } else {
          print('wrong code stop trying to hack our requests');
          return showDialog(
                  context: context,
                  builder: (context) => errorReg
                );
        }

      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    }

    Future scan() async {
      try {
        var barcode = await BarcodeScanner.scan();
        var codeStr = barcode.rawContent;
        validateReg(codeStr, widget.userInfo.uid);

        //setState(() => this._barcodeString = barcode.rawContent);
      } on PlatformException catch (e) {
        if (e.code == BarcodeScanner.cameraAccessDenied) {
          setState(() {
            this._barcodeString = 'The user did not grant the camera permission!';
          });
        } else {
          setState(() => this._barcodeString = 'Error: $e');
        }
      } on FormatException{
        setState(() => this._barcodeString = 'null (User returned using the "back"-button before scanning anything. Result)');
      } catch (e) {
        setState(() => this._barcodeString = 'Error: $e');
      }
    }

    return new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: scan,
                    child: const Text('START CAMERA SCAN')
                ),
              )
              ,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(_barcodeString, textAlign: TextAlign.center,),
              )
              ,
            ],
          )
        );   
  }
}




