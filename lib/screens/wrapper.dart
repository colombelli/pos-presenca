import 'package:flutter/material.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/screens/authenticate/authenticate.dart';
import 'package:pg_check/screens/professor/professor.dart';
import 'package:pg_check/screens/program/program.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pg_check/screens/student/student_home.dart';
import 'package:pg_check/shared/loading.dart';


class Wrapper extends StatelessWidget {

  getUserWidget(userInfo) {

    if (userInfo.type == "student"){
      return StudentHome(userInfo: userInfo);

    } else if (userInfo.type == "program"){
      return ProgramHome(userInfo: userInfo);

    } else if (userInfo.type == "professor") {
      return ProfessorHome(userInfo: userInfo);
    }

  }

  @override
  Widget build(BuildContext context) {
    
    final user = Provider.of<User>(context);  

   if (user == null) {
     return Authenticate();
   } else {

    return new StreamBuilder(
      stream: Firestore.instance.collection('users').document(user.uid).snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return Loading(); 
        } else {
          var userDocument = snapshot.data;
          final userInfo = User(uid: user.uid, type: userDocument['type'], name: userDocument['name'], program: userDocument['program']);
          
          return getUserWidget(userInfo);
        }
      },
    );
   }
  }
}