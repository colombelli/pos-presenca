import 'package:flutter/material.dart';
import 'package:pg_check/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pg_check/screens/program/accredit_justification.dart';
import 'package:pg_check/shared/loading.dart';

/* pega faltas da coleção absences do aluno que não tenham justificativa, ele seleciona a que quiser e
insere seru motivo */

class StudentAbsencesJustification extends StatefulWidget {
  final User userInfo;
  StudentAbsencesJustification({key, this.userInfo}): super(key: key);

  @override
  _StudentAbsencesJustificationState createState() => _StudentAbsencesJustificationState();
}

class _StudentAbsencesJustificationState extends State<StudentAbsencesJustification> {

  int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  Stream getAllWeeksWithUnjustifiedAbsences() async* {
    var firestone = Firestore.instance;
    QuerySnapshot qnWA;
    List totalAbsences;
    Map unjustifiedWeeks = new Map();

    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (studentList) async {
      if (studentList.documents.length > 0){
          await studentList.documents[0].reference.collection("students").where("name", isEqualTo: widget.userInfo.name).limit(1).getDocuments().then( (absencesList) async {
            qnWA = await absencesList.documents[0].reference.collection('absences').orderBy('date', descending: true).getDocuments();
            totalAbsences = qnWA.documents.where((element) => element.data["justified"] == false).toList();
            totalAbsences.forEach((absenceDay) {
              int weekNumber = getWeekNumber(DateTime.parse(absenceDay.data["date"].toDate().toString()));
              List absencesOnWeek = unjustifiedWeeks.containsKey(weekNumber) ? unjustifiedWeeks[weekNumber] : new List();
              absencesOnWeek.add(absenceDay);
              unjustifiedWeeks[weekNumber] = absencesOnWeek;
            });
          });
        }
      }
    );
    yield unjustifiedWeeks;
  }

  navigateToDetails(List absences) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(absences: absences, userInfo: widget.userInfo)));
  }

  String formatDays(List days) {
    String formattedDays = DateFormat('d/M/y').format( DateTime.parse(days[days.length-1].data['date'].toDate().toString()));
    for(int i = days.length-2; i >= 0; i--) {
      formattedDays += ',  ' + DateFormat('d/M/y').format( DateTime.parse(days[i].data['date'].toDate().toString()));
    }
    return formattedDays;
  }

  @override 
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder(
          stream: getAllWeeksWithUnjustifiedAbsences(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                
                child: Loading(),
              );
            } else if (snapshot.data.isNotEmpty) {
              List keys = snapshot.data.keys.toList();
              return ListView.builder(
                  itemCount: keys.length,
                  itemBuilder: (_, index){
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.orange[700],),
                        title: Text(formatDays(snapshot.data[keys[index]]), style: TextStyle(color: Colors.orange[700])),
                        onTap: () {
                          navigateToDetails(snapshot.data[keys[index]]);
                        },
                      ),
                    );
                });
          } else {
                //return Center(child: Text("There are no registered absences for that student"),);
                return Center(child: Text("Não existem faltas registradas para este aluno.", style: TextStyle(color: Colors.white),),);
          }
        }),
      );
  }
}

class DetailsPage extends StatefulWidget {
  final List absences;
  final User userInfo;
  DetailsPage({ this.absences, key, this.userInfo}): super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
} 

class _DetailsPageState extends State<DetailsPage> {


  String justification = '';

    
  Future setJustification() async {
    var firestone = Firestore.instance;
    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (studentList) async {
      if (studentList.documents.length > 0){
          await studentList.documents[0].reference.collection("students")
          .where("name", isEqualTo: widget.userInfo.name).limit(1).getDocuments()
          .then( (studColl) {
            widget.absences.forEach((absence) async {
              await studColl.documents[0].reference.collection("absences")
              .document(absence.documentID)
              .updateData(
                {
                  'justification': justification,
                  'justified': true,
                  "status": "unchecked"
                }
              );
            });
          });  
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    Widget continueButton = FlatButton(
        child: Text("Continuar", style: TextStyle(color: Colors.orange[700]),),
        onPressed:  () {
          Navigator.popAndPushNamed(context, '/');
        },
    );

    AlertDialog success = AlertDialog(
      title: Text("Enviado"),
      content: Text("A justificativa foi salva no seu histórico"),
      actions: [
        continueButton
      ],
    );
    
    AlertDialog emptyJustification = AlertDialog(
      title: Text("Nenhuma justificativa inserida"),
      actions: [
        continueButton
      ],
    );

    Widget sendButton = FlatButton(
        child: Text("Enviar", style: TextStyle(color: Colors.orange[700]),),
        onPressed:  () async {
              if(justification.isNotEmpty) {
                await setJustification();
                Navigator.pop(context);
                return showDialog(
                  context: context,
                  builder: (context) => success
                );
              } 
              return showDialog(
                  context: context,
                  builder: (context) => emptyJustification
                );
            
        },
    );
    
    Widget cancelButton = FlatButton(
        child: Text("Cancelar", style: TextStyle(color: Colors.orange[700]),),
        onPressed:  () {Navigator.pop(context);},
    );

    // set up the AlertDialog
    AlertDialog confirmDialog = AlertDialog(
      title: Text("Confimação"),
      content: Text("Tem certeza que deseja enviar esta justificativa?"),
      actions: [
        cancelButton,
        sendButton
      ],
    );

    // set up the AlertDialog
    
    
    return Scaffold(
      backgroundColor: Colors.orange[700],
      
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.orange[700],
        title: Text(formatDays(widget.absences)),
      ),
      body: ListView(
        children: <Widget> [
          Padding(
          padding: const EdgeInsets.all(8.0),
          child: 
          Card(
            child: Column(
              children: <Widget> [
                ListTile(
                  leading: Icon(Icons.message, color: Colors.orange[700]),
                  title: Text("Justificativa:", style: TextStyle(color: Colors.orange[700]),),
                  subtitle: Text(''),
                ),
              
              Padding(
              padding: const EdgeInsets.all(8.0),
              child:
              TextFormField(
//                cursorColor: Colors.deepOrange,
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                controller: TextEditingController(),
                onChanged: (String value) {
                  justification = value;
                },
                decoration: InputDecoration(
                  labelText: "Digite a justificativa",
                  hintText: " ",
                  alignLabelWithHint: true,
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderSide: new BorderSide(),
                  )
                ),
              ),
              ),
              SizedBox(height: 10),

              RaisedButton(
                    color: Colors.orange[700],
                    textColor: Colors.white,
                    splashColor: Colors.deepOrange,
                    onPressed: () => {
                      showDialog(
                        context: context,
                        builder: (context) => confirmDialog
                      )
                    },
                    child: const Text('Enviar')
                ),


              /*onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => 
                    JustificationPage(absenceID: widget.absence.documentID, userInfo: widget.userInfo)));
              }*/
              ]),
          ),
          )
        ]
      ),
    );
  }
}