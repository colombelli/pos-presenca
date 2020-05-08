import 'package:flutter/material.dart';
import 'package:pg_check/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   
   // return either home or authenticate widget
    return Home();
  }
}