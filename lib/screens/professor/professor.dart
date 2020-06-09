import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Professor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: new AppBar(
        leading: Icon(Icons.school),
        title: new Text("Your Students"),
      ),

      body: StudentListPage(),
    );
  }
}

class StudentListPage extends StatefulWidget {
  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {

  Future _data;

  Future getStudents() async {
    var firestone = Firestore.instance;
    QuerySnapshot  qn;
    await firestone.collection("programs").where("name", isEqualTo: "PPGC").limit(1).getDocuments().then( (data) async {
      if (data.documents.length > 0){
          qn = await data.documents[0].reference.collection("students").getDocuments();
        }
      }
    );
    return qn.documents;//.where((snapshot) => snapshot.data.containsValue("professor"));
  }

  navigateToAbsences(DocumentSnapshot student) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AbsencesPage(student: student,)));
  }

  @override
  void initState() {
    super.initState();
    _data = getStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _data,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(), //Text("Loading..."),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (_, index){

                return Card(
                  child: ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text(snapshot.data[index].data['name']),
                    onTap: () => navigateToAbsences(snapshot.data[index]),
                  ),
                );
            });
        }
      }),
    );
  }
}

class DisplayField extends StatelessWidget {

  final String _field;
  final String _information;
  DisplayField(this._field, this._information);

  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

class AbsencesPage extends StatefulWidget {

  final DocumentSnapshot student;
  AbsencesPage({this.student});

  @override
  _AbsencesPageState createState() => _AbsencesPageState();
}

class _AbsencesPageState extends State<AbsencesPage> {

  Future _data;

  Future getAbsences() async {
    var firestone = Firestore.instance;
    QuerySnapshot  qn;

    await firestone.collection("programs").where("name", isEqualTo: "PPGC").limit(1).getDocuments().then( (data) async {
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(absence: absence,)));
  }

  @override
  void initState() {
    super.initState();
    _data = getAbsences();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text(widget.student.data['name']), ),
      body: Container(
        child: FutureBuilder(
          future: _data,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                
                child: CircularProgressIndicator(), //Text("Loading..."),
              );
            } else if (snapshot.data.isNotEmpty) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index){
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.calendar_today),
                        title: Text(DateFormat('yMd').format(DateTime.parse(snapshot.data[index].data['date'].toDate().toString()))),
                        onTap: () => navigateToDetails(snapshot.data[index]),
                      ),
                    );
                });
          } else {
                return Center(child: Text("There are no registered absences for that student"),);
          }
        }),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final DocumentSnapshot absence;

  DetailsPage({this.absence});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

  Widget box({width: 100.0, height: 100.0}) => Container(
        width: width,
        height: height,
        color: Colors.grey,
  );

class _DetailsPageState extends State<DetailsPage> {

  buildBox(double _width, double _height) {
    return Container(
      width: _width,
      height: _height,
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('yMd').format(DateTime.parse(widget.absence.data['date'].toDate().toString()))),
      ),
      body: ListView(
        children: <Widget> [
          Card(
            child: ListTile(
              leading: Icon(widget.absence.data['justified'] ? Icons.sentiment_satisfied: Icons.sentiment_dissatisfied),
              title: Text("Justified"),
              subtitle: Text( (widget.absence.data['justified']) ? "Yes" : "No" ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(widget.absence.data['justified'] ? Icons.message: Icons.speaker_notes_off),
              title: Text("Justification"),
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