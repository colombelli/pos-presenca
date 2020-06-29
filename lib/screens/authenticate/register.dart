import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/shared/constants.dart';
import 'package:pg_check/shared/loading.dart';
import 'package:pg_check/services/database.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pg_check/models/program.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/screens/authenticate/prof_drop.dart';

class Register extends StatefulWidget {

  final Function toggleView;
  final List<DropdownMenuItem<Program>> availablePrograms;
  Register({ this.toggleView, this.availablePrograms });

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {


  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // text field state
  String name = '';
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  String userType;
  
  Program selectedProgram;
  User selectedProfessor;


  @override
  void initState() { 
    super.initState();
    userType="student";

    selectedProgram = widget.availablePrograms[0].value;

  }

  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    callbackSetProfessor(newProfessor) {
        setState(() {
          selectedProfessor = newProfessor;
        });
  }

    return Scaffold (
        backgroundColor: Colors.orange[700],
        appBar: AppBar(
          backgroundColor: Colors.orange[700],
          elevation: 0.0,
          title: Text(translation('sign_up_title')),
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text(translation('sign_in_text')),
              onPressed: () {
                widget.toggleView();
              },  
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),

                DropdownButton(
                  value: selectedProgram,
                  items: widget.availablePrograms,
                  
                  onChanged: (selected) {
                    setState(() {
                      selectedProgram = selected;
                    });
                  },
                ),

                SizedBox(height: 20.0),
                
                    ListTile(
                      title: Text(translation("student"), style: TextStyle(color: Colors.white),),
                      leading: Radio(
                        value: "student",
                        groupValue: userType,
                        onChanged: (String value) {
                          setState(() {
                            userType = value;
                          });
                        },
                      ),
                    ),

                    ListTile(
                      title: Text(translation("professor"), style: TextStyle(color: Colors.white),),
                      leading: Radio(
                        value: "professor",
                        groupValue: userType,
                        onChanged: (String value) {
                          setState(() {
                            userType = value;
                          });
                        },
                      ),
                    ),
                
                ProfessorDrop(typeOfUser: userType, 
                  callbackNewProfessor: callbackSetProfessor, 
                  selectedProgram: selectedProgram,
                  selectedProfessor: selectedProfessor,),


                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    hintText: translation("name_hint"),
                  ),
                  validator: (value) => value.isEmpty ? translation('name_empty') : null,
                  onChanged: (value){
                    setState(() => name = value);
                  },
                ),

                SizedBox(height: 20.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    hintText: translation("email_hint"),
                  ),
                  validator: (value) => value.isEmpty ? translation('email_empty') : null,
                  onChanged: (value){
                    setState(() => email = value);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    hintText: translation("password_hint")
                  ),
                  validator: (value) => value.length < 6 ? translation('short_pass') : null,
                  obscureText: true,
                  onChanged: (value) {
                    setState(() => password = value);
                  }
                ),
                SizedBox(height: 20.0),
                RaisedButton(
                  color: Colors.deepOrange,
                  child: Text(
                    translation('sign_up_text'), 
                    style: TextStyle(color: Colors.white)
                    ),
                  onPressed: () async {
                    if(_formKey.currentState.validate()){

                      setState(() => loading = true);
                      
                      User newUser = User(uid: "willNotBeUsed", type: userType, name: name, 
                                          program: selectedProgram.name);
                      dynamic results = await _auth
                      .registerEmailPassword(email, password, newUser, 
                          selectedProgram.uid, selectedProfessor.name);
                      if(results == null){
                        print("ERROR IN THE USER CREATION");
                        setState(() {
                          error = translation('invalid_email_error');
                          setState(() => loading = false);
                        });
                      }
                    }
                  },
                ),
                SizedBox(height: 20.0),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0)
                  ),
              ],
            ),
            ),
          ),
        );
  }
}



