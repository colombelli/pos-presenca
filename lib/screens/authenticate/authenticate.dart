import 'package:flutter/material.dart';
import 'package:pg_check/screens/authenticate/register.dart';
import 'package:pg_check/screens/authenticate/sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:pg_check/services/database.dart';
import 'package:pg_check/models/program.dart';
import 'package:pg_check/shared/loading.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  
  bool loading = false;
  bool showSignIn = true;

  Program selectedProgram;
  
  
  List<DropdownMenuItem<Program>> availablePrograms;
  List<DropdownMenuItem<Program>> buildDropdownMenuItems(List programs){

    List<DropdownMenuItem<Program>> items = List();
    for (Program program in programs) {
      items.add(
        DropdownMenuItem(
          value: program, 
          child: new Text(program.name)//, style: TextStyle(color: Colors.orange[700]),)
        )
      );
    }
    return items;
  }

  void toggleView () {
    setState(() {
        showSignIn = !showSignIn;
    });
  }


  dbWrapper() async {
    final programFireBase = await DatabaseService().programsCollection.getDocuments();

    final List<Program> programs = [];

    if(programFireBase == null){
      loading = true;
    } else {

      for (var doc in programFireBase.documents) {
        programs.add(Program(uid: doc.documentID, name: doc.data["name"]));
      }
      availablePrograms = buildDropdownMenuItems(programs);

      loading = false;
    } 
  }


  @override
  Widget build(BuildContext context) {
    
    dbWrapper();


    if (showSignIn) {
      return SignIn(toggleView: toggleView);
    } else {
        return loading ? Loading() : Register(toggleView: toggleView, availablePrograms: availablePrograms,);
    }

  }
}