
import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/*
  Essa pagina se refere a visualização das faltas da semana
  Ela aparece quando se clica em ver as faltas da semana na conta do ppg
  ! provavelmente deve ser modificada para juntar com o processamento de faltas
*/

class WeekAbsencesReview extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: new AppBar(
//        leading: Icon(Icons.school),
        title: new Text("Faltas da semana"),
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

      body: WeekAbsences(),
    );
  }
}

class WeekAbsences extends StatefulWidget {
  @override
  _WeekAbsencesState createState() => _WeekAbsencesState();
}

class _WeekAbsencesState extends State<WeekAbsences> {

  Future _data;

  Future getStudents() async {
    var firestone = Firestore.instance;
    QuerySnapshot  qn;
    await firestone.collection("programs").where("name", isEqualTo: "PPGC").limit(1).getDocuments().then( (data) async { // ! Mudar programa para refletir usuário
      if (data.documents.length > 0){
        qn = await data.documents[0].reference.collection("students").getDocuments();
        }
    } );
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
              itemBuilder: (_, index) {

                print(snapshot.data[index].reference.collection("weekAbsences").snapshots().length.toString());

                if (snapshot.data[index].reference.collection("weekAbsences").snapshots().length != 0) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text(snapshot.data[index].data['name']),
                      onTap: () => navigateToAbsences(snapshot.data[index]),
                    ),
                  );
                }
            });
        }
      }),
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
            qn = await atad.documents[0].reference.collection('weekAbsences').orderBy('date').getDocuments();
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
      appBar: AppBar(
       // leading: Icon(Icons.person_outline),
        title: Text("Faltas de ${widget.student.data['name']}"),
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

  DetailsPage({this.absence});

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
              subtitle: Text( (widget.absence.data['justified']) ? "Sim" : "Não" ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(widget.absence.data['justified'] ? Icons.message: Icons.speaker_notes_off),
              title: Text("Justificativa:"),
              subtitle: Text(widget.absence.data['justification']),
            ),
          ),
        ]
      ),
    );
  }
}