import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';


class StudentPresenceRegistration extends StatefulWidget {
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


  Future scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      setState(() => this._barcodeString = barcode.rawContent);
      print(barcode.rawContent);
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
}




