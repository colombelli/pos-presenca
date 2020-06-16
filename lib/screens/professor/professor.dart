import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfessorHome extends StatelessWidget {
  final User userInfo;
  ProfessorHome({ Key key, this.userInfo}): super(key: key);

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: new AppBar(
        leading: Icon(Icons.school),
        title: new Text("Seus Alunos"),
        backgroundColor: Colors.orange[700],
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person,),
            onPressed: () async {
              await _auth.signOut();  // and does nothing else because there's a streaming 
                                      // already/*  */ hearing the value of User and when it is null
                                      // it renders the Authenticate screen instead of Home
            },
            label: Text(translation('logout_button')),
          )
        ]
      ),

      body: StudentListPage(userInfo: userInfo),
    );
  }
}

class StudentListPage extends StatefulWidget {
  final User userInfo;
  StudentListPage({ Key key, this.userInfo}): super(key: key);

  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  Future _data;

  Future getStudents() async {
    var firestone = Firestore.instance;
    QuerySnapshot  qn;
    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (data) async {
      if (data.documents.length > 0){
          qn = await data.documents[0].reference.collection("students").where("professor", isEqualTo: widget.userInfo.name).getDocuments();
        }
      }
    );
    return qn.documents;//.where((snapshot) => snapshot.data.containsValue("professor"));
  }

  navigateToAbsences(DocumentSnapshot student) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AbsencesPage(student: student, userInfo: widget.userInfo)));
  }

  @override
  void initState() {
    super.initState();
    _data = getStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange[700],
      child: FutureBuilder(
        future: _data,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Loading(), 
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (_, index){
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.person_outline, color: Colors.orange[700]),
                    title: Text(snapshot.data[index].data['name'], style: TextStyle(color: Colors.orange[700]),),
                    onTap: () => navigateToAbsences(snapshot.data[index]),
                  ),
                );
            });
        }
      }),
    );
  }
}
class AbsencesPage extends StatefulWidget {
  final User userInfo;
  AbsencesPage({ this.student, key, this.userInfo}): super(key: key);

  final DocumentSnapshot student;

  @override
  _AbsencesPageState createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {
  Future _data;

  Future getAbsences() async {
    var firestone = Firestore.instance;
    QuerySnapshot  qn;

    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (data) async {
      if (data.documents.length > 0){
          await data.documents[0].reference.collection("students").where("name", isEqualTo: widget.student.data['name']).limit(1).getDocuments().then( (atad) async {
            qn = await atad.documents[0].reference.collection('absences').orderBy('date').getDocuments();
          });
        }
      }
    );

    return qn.documents;//.where((snapshot) => snapshot.data.containsValue("professor"));
  }

  navigateToDetails(DocumentSnapshot absence) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(absence: absence, userInfo: widget.userInfo)));
  }

  @override
  void initState() {
    super.initState();
    _data = getAbsences();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        elevation: 0.0,
       // leading: Icon(Icons.person_outline),
        title: Text("Faltas de ${widget.student.data['name']}"),
       ),
      body: Container(
        color: Colors.orange[700],
        child: FutureBuilder(
          future: _data,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                
                child: Loading(),
              );
            } else if (snapshot.data.isNotEmpty) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index){
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.orange[700]),
                        title: Text(DateFormat('yMd').format(DateTime.parse(snapshot.data[index].data['date'].toDate().toString())), style: TextStyle(color: Colors.orange[700]),),
                        onTap: () => navigateToDetails(snapshot.data[index]),
                      ),
                    );
                });
          } else {
                //return Center(child: Text("There are no registered absences for that student"),);
                return Center(child: Text("Não existem faltas registradas para este aluno.", style: TextStyle(color: Colors.white),),);
          }
        }),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final DocumentSnapshot absence;
  final User userInfo;
  DetailsPage({ this.absence, key, this.userInfo}): super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}
class _DetailsPageState extends State<DetailsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[700],
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        elevation: 0.0,
        title: Text(DateFormat('yMd').format(DateTime.parse(widget.absence.data['date'].toDate().toString()))),
      ),
      body: ListView(
        children: <Widget> [
          Card(
            child: ListTile(
              leading: Icon(widget.absence.data['justified'] ? Icons.sentiment_satisfied: Icons.sentiment_dissatisfied, color: Colors.orange[700]),
              title: Text("Justificado:", style: TextStyle(color: Colors.orange[700])),
              subtitle: Text( (widget.absence.data['justified']) ? "Sim" : "Não", style: TextStyle( color: widget.absence.data['justified'] ? Colors.yellow[400] : Color.fromRGBO(147, 107, 9, 100),)),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(widget.absence.data['justified'] ? Icons.message: Icons.speaker_notes_off, color: Colors.orange[700]),
              title: Text("Justificativa:", style: TextStyle(color: Colors.orange[700])),
              subtitle: Text(widget.absence.data['justification']),
            ),
          ),
        ]
      ),
    );
  }
}

//for student in student:
//  if student.professor == professor:
//     //display student name in initial list
//
//    for absence in absences: // if student name is clicked the following happens in a new page
//      if absence.student == student:
//        //show absence date
//
//        if date.isClicked():
//          // show date, hour, justified, justification, etc