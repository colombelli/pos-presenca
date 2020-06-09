import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/screens/authenticate/authenticate.dart';
import 'package:pg_check/screens/home/home.dart';
import 'package:pg_check/screens/professor/professor.dart';
import 'package:pg_check/screens/program/program.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    final user = Provider.of<User>(context);  

   if (user == null) {
     return Authenticate();
   } else {
     return Professor();
//     return Program();
   }
  }
}