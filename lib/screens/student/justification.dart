import 'package:flutter/material.dart';
import 'package:pg_check/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StudentAbsencesJustification extends StatefulWidget {
  final User userInfo;
  StudentAbsencesJustification({key, this.userInfo}): super(key: key);

  @override
  _StudentAbsencesJustificationState createState() => _StudentAbsencesJustificationState();
}

class _StudentAbsencesJustificationState extends State<StudentAbsencesJustification> {
  Future _data;

  Future getWeekAbsences() async {
    var firestone = Firestore.instance;
    QuerySnapshot qnA, qnWA;
    List totalAbsences;

    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (studentList) async {
      if (studentList.documents.length > 0){
          await studentList.documents[0].reference.collection("students").where("name", isEqualTo: widget.userInfo.name).limit(1).getDocuments().then( (absencesList) async {
            qnA = await absencesList.documents[0].reference.collection('absences').orderBy('date', descending: true).getDocuments();
            qnWA = await absencesList.documents[0].reference.collection('weekAbsences').orderBy('date', descending: true).getDocuments();

            totalAbsences = qnWA.documents;
            totalAbsences.addAll(qnA.documents);
          });
        }
      }
    );
    return totalAbsences;
  }

  navigateToDetails(DocumentSnapshot absence) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(absence: absence, userInfo: widget.userInfo)));
  }

  @override
  void initState() {
    super.initState();
    _data = getWeekAbsences();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // leading: Icon(Icons.person_outline),
        title: Text("Faltas de ${widget.userInfo.name}"),
       ),
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
                //return Center(child: Text("There are no registered absences for that student"),);
                return Center(child: Text("Não existem faltas registradas para este aluno."),);
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
      appBar: AppBar(
        title: Text(DateFormat('yMd').format(DateTime.parse(widget.absence.data['date'].toDate().toString()))),
      ),
      body: ListView(
        children: <Widget> [
          Card(
            child: ListTile(
              leading: Icon(widget.absence.data['justified'] ? Icons.sentiment_satisfied: Icons.sentiment_dissatisfied),
              title: Text("Justificado:"),
              subtitle: Text(
                widget.absence.data['justified'] ? "Sim" : "Não",
                style: TextStyle(color: widget.absence.data['justified'] ? Colors.green[400] : Colors.red[400])), 
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(widget.absence.data['justified'] ? Icons.message: Icons.speaker_notes_off),
              title: Text("Justificativa:"),
              subtitle: Text(widget.absence.data['justification']),
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => 
                    JustificationPage(absenceDate: widget.absence.data['date'], userInfo: widget.userInfo)));
              }
            ),
          ),
        ]
      ),
    );
  }
}

class JustificationPage extends StatefulWidget {
  final Timestamp absenceDate;
  final User userInfo;
  JustificationPage({ this.absenceDate, key, this.userInfo}): super(key: key);

  @override
  _JustificationPageState createState() => _JustificationPageState();
}

class _JustificationPageState extends State<JustificationPage> {

  Future _data;

  Future getJustification() async {
    var firestone = Firestore.instance;
    QuerySnapshot qn;

    DocumentSnapshot absence;

    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (studentList) async {
      if (studentList.documents.length > 0){
          await studentList.documents[0].reference.collection("students").where("name", isEqualTo: widget.userInfo.name).limit(1).getDocuments().then( (absencesList) async {
            qn = await absencesList.documents[0].reference.collection('absences').orderBy('date', descending: true).getDocuments();
            qn.documents.forEach((abs) { 
              if (abs['date'] == widget.absenceDate) {
                absence = abs;
              }
            });
            qn = await absencesList.documents[0].reference.collection('weekAbsences').orderBy('date', descending: true).getDocuments();
            qn.documents.forEach((abs) { 
              if (abs['date'] == widget.absenceDate) {
                absence = abs;
              }
            });
          });
        }
      }
    );
    return absence;
  }

  @override
  void initState() {
    super.initState();
    _data = getJustification();
  }

  final _formKey = GlobalKey<FormState>();
  String justification;

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // leading: Icon(Icons.person_outline),
        title: Text("Faltas de ${widget.userInfo.name}"),
        actions: <Widget>[
          MaterialButton(
            key: _formKey,
            child: Text("Enviar", style: TextStyle(color: Colors.white)),
            onPressed: () {
              print(justification);
              _formKey.currentState.save();
            },
          ),
        ],
       ),
      body: Container(
        child: FutureBuilder(
          future: _data,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                
                child: CircularProgressIndicator(), //Text("Loading..."),
              );
            } else if (snapshot.data != null) {
              return TextFormField(
                controller: TextEditingController(
                  text: snapshot.data['justification']
                  ),
                onSaved: (String value) {
                  justification = value;
                },
              );                
          } else {
                return Center(child: Text("Não existem faltas registradas para este aluno."),);
          }
        }),
      ),
    );
  }
}