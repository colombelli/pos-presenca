import 'package:flutter/material.dart';
import 'package:pg_check/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/* pega faltas da coleção absences do aluno que não tenham justificativa, ele seleciona a que quiser e
insere seru motivo */

class ProgramAbsencesAccredit extends StatefulWidget {
  final User userInfo;
  ProgramAbsencesAccredit({key, this.userInfo}): super(key: key);

  @override
  _ProgramAbsencesAccreditState createState() => _ProgramAbsencesAccreditState();
}

class _ProgramAbsencesAccreditState extends State<ProgramAbsencesAccredit> {
  Future _data;

  Future getUncheckedStudents() async {
    var firestone = Firestore.instance;
    List<DocumentSnapshot> uncheckedStudents = new List();
/* ta feio, mas o que isso faz é, pega todos os estudantes de um programa, 
vê se cada um tem justificativas inseridas e vê o status
delas, e se tiver unchecked, ele faz a volta e devolve o estudante, 
e no fim tu tem uma lista de todos os que tem justificativa pendente */
    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (programCollections) async {
      if (programCollections.documents.length > 0){
        await programCollections.documents[0].reference.collection("students").getDocuments().then( (students) {
          if(students.documents.length > 0) {
            students.documents.forEach((student) async {
              await student.reference.collection('absences').orderBy('date', descending: true).getDocuments().then((qnWA) {
                List<DocumentSnapshot> studentHasUncheckedJustifications = 
                  qnWA.documents.where((element) => element.data["justified"] == true && element.data["status"] == 'unchecked').toList();
                if (studentHasUncheckedJustifications.length > 0) {
                  uncheckedStudents.add(student);
                }
              });
            });
          }
        });
      }
    });    
    return uncheckedStudents;
  }

  navigateToAbsences(DocumentSnapshot student) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AbsencesPage(student: student, userInfo: widget.userInfo)));
  }

  @override
  void initState() {
    super.initState();
    _data = getUncheckedStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Justificativas"),
      ),
      body: Container(
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
      )
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

    return qn.documents.where((absence) => absence.data['status'] == 'unchecked').toList();
  }

  navigateToDetails(DocumentSnapshot absence, DocumentSnapshot student) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(absence: absence, student: student, userInfo: widget.userInfo)));
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
                        onTap: () => navigateToDetails(snapshot.data[index], widget.student),
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
  final DocumentSnapshot student;
  final User userInfo;
  DetailsPage({ this.absence, this.student, key, this.userInfo}): super(key: key);

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
      body: Column(
        children: <Widget> [
          Card(
            child: ListTile(
              leading: Icon(widget.absence.data['justified'] ? Icons.message: Icons.speaker_notes_off),
              title: Text("Justificativa:"),
              subtitle: Text(widget.absence.data['justification']),
            ),
          ),
          Row(
            children: <Widget>[
              FlatButton(
                child: Text("Rejeitar"),
                onPressed:  () {
                  changeJustificationStatus("rejected");
                  Navigator.pop(context);
                  Navigator.pop(context);
                },                
              ),
              FlatButton(
                child: Text("Abonar"),
                onPressed:  () {
                  changeJustificationStatus("accredited");
                  Navigator.pop(context);
                  Navigator.pop(context);
                },                
              )
            ],
          )
        ]
      ),
    );
  }

    Future changeJustificationStatus( String newStatus ) async {
    var firestone = Firestore.instance;
    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (studentList) async {
      if (studentList.documents.length > 0){
          await studentList.documents[0].reference.collection("students")
          .where("name", isEqualTo: widget.student.data['name']).limit(1).getDocuments()
          .then( (absencesList) async {
            await absencesList.documents[0].reference.collection("absences")
            .document(widget.absence.documentID)
            .updateData(
            {
              "status": newStatus
            });
          });  
        }
      }
    );
  }
}