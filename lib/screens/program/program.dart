import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/screens/program/week_absences_review.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/screens/program/presence_reg.dart';
import 'package:pg_check/screens/student/history.dart';

class ProgramHome extends StatelessWidget {
  final User userInfo;
  ProgramHome({ Key key, this.userInfo}): super(key: key);

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: new AppBar(
        leading: Icon(Icons.account_balance),
        title: new Text("Menu PPGC"),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            onPressed: () async {
              await _auth.signOut();
            },
            label: Text(translation('logout_button')),
          )
        ]
      ),
      body: MenuList(),
    );
  }
}

//Menu:
//- justification
//- process weekly
//- view absences

class MenuList extends StatefulWidget {
  @override
  _MenuListState createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {

  navigateToPreviousAbsencesCalendar() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => History()));
  }

  navigateToPresenceRegistration() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PresenceRegistration()));
  }
  
  navigateToWeekAbsencesReview() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => WeekAbsencesReview()));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
//          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget> [
  
            ButtonTheme(
              minWidth: 300,
              child: new RaisedButton(
                child: new Text("Registar presenças"),
                color: Colors.white,
                textColor: Colors.blue[500],
                disabledColor: Colors.white,
                disabledTextColor: Colors.blue[400],
                padding: EdgeInsets.all(35.0),
                elevation: 2.0,
                disabledElevation: 2.0,
                //shape: RoundedRectangleBorder(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                  //borderRadius: new BorderRadius.circular(0.0),
                  side: BorderSide(color: Colors.blue[400]),
                ),
                onPressed: () => navigateToPresenceRegistration(),
              ),
            ),
  
            SizedBox(height: 15,),

            ButtonTheme(
              minWidth: 300,
              child: new RaisedButton(
                child: new Text("Justificativas Pendentes"),
                color: Colors.white,
                textColor: Colors.blue[500],
                disabledColor: Colors.white,
                disabledTextColor: Colors.blue[400],
                padding: EdgeInsets.all(35.0),
                elevation: 2.0,
                disabledElevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                  //borderRadius: new BorderRadius.circular(0.0),
                  side: BorderSide(color: Colors.blue[400]),
                ),
                onPressed: null,
              ),
            ),
  
            SizedBox(height: 15,),
              
            ButtonTheme(
              minWidth: 300,
              child: new RaisedButton(
                child: new Text("Faltas da semana"),
                color: Colors.white,
                textColor: Colors.blue[500],
                disabledColor: Colors.white,
                disabledTextColor: Colors.blue[400],
                padding: EdgeInsets.all(35.0),
                elevation: 2.0,
                disabledElevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                  //borderRadius: new BorderRadius.circular(0.0),
                  side: BorderSide(color: Colors.blue[400]),
                 ),
                onPressed: () => navigateToWeekAbsencesReview(),
              ),
            ),
 
            SizedBox(height: 15,),

            ButtonTheme(
              minWidth: 300,
              child: new RaisedButton(
                child: new Text("Processar faltas"),
                color: Colors.white,
                textColor: Colors.blue[500],
                disabledColor: Colors.white,
                disabledTextColor: Colors.blue[400],
                padding: EdgeInsets.all(35.0),
                elevation: 2.0,
                disabledElevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                  //borderRadius: new BorderRadius.circular(0.0),
                  side: BorderSide(color: Colors.blue[400]),
                ), 
                onPressed: () => navigateToPreviousAbsencesCalendar(),
              ),
            ),
          ]    
        ),
      )
    );
//    return ListView(
//      children: <Widget>[
//      ],
//    );
  }
}
