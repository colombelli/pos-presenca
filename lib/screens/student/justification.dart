import 'package:flutter/material.dart';
import 'package:pg_check/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/* pega faltas da coleção absences do aluno que não tenham justificativa, ele seleciona a que quiser e
insere seru motivo */

class StudentAbsencesJustification extends StatefulWidget {
  final User userInfo;
  StudentAbsencesJustification({key, this.userInfo}): super(key: key);

  @override
  _StudentAbsencesJustificationState createState() => _StudentAbsencesJustificationState();
}

class _StudentAbsencesJustificationState extends State<StudentAbsencesJustification> {

  Stream getAllAbsences() async* {
    var firestone = Firestore.instance;
    QuerySnapshot qnWA;
    List totalAbsences;

    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (studentList) async {
      if (studentList.documents.length > 0){
          await studentList.documents[0].reference.collection("students").where("name", isEqualTo: widget.userInfo.name).limit(1).getDocuments().then( (absencesList) async {
            qnWA = await absencesList.documents[0].reference.collection('absences').orderBy('date', descending: true).getDocuments();

            totalAbsences = qnWA.documents.where((element) => element.data["justified"] == false).toList();
          });
        }
      }
    );
    yield totalAbsences;
  }

  navigateToDetails(DocumentSnapshot absence) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(absence: absence, userInfo: widget.userInfo)));
  }

  @override 
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder(
          stream: getAllAbsences(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data.isNotEmpty) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index){
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.calendar_today, color: Colors.orange[700],),
                        title: Text(DateFormat('yMd').format(DateTime.parse(snapshot.data[index].data['date'].toDate().toString())), style: TextStyle(color: Colors.orange[700]),),
                        onTap: () {
                          navigateToDetails(snapshot.data[index]);
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
  final DocumentSnapshot absence;
  final User userInfo;
  DetailsPage({ this.absence, key, this.userInfo}): super(key: key);

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
          .then( (absencesList) async {
            await absencesList.documents[0].reference.collection("absences")
            .document(widget.absence.documentID)
            .updateData(
              {
                'justification': justification,
                'justified': true,
                "status": "unchecked"
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
        title: Text(DateFormat('yMd').format(DateTime.parse(widget.absence.data['date'].toDate().toString()))),
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
                  subtitle: Text(widget.absence.data['justification']),
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

class JustificationPage extends StatefulWidget {
  final String absenceID;
  final User userInfo;
  JustificationPage({ this.absenceID, key, this.userInfo}): super(key: key);

  @override
  _JustificationPageState createState() => _JustificationPageState();
}

class _JustificationPageState extends State<JustificationPage> {
  @override
  void initState() {
    super.initState();
  }

  String justification='';

  @override 
  Widget build(BuildContext context) {

    // ! investigar como voltar melhor tá díficil
    Widget continueButton = FlatButton(
        child: Text("Continuar", style: TextStyle(color: Colors.orange[700]),),
        onPressed:  () {
          Navigator.popAndPushNamed(context, '/');
        },
    );

    // set up the AlertDialog
    AlertDialog success = AlertDialog(
      title: Text("Enviado"),
      content: Text("A justificativa foi salva no seu histórico"),
      actions: [
        continueButton
      ],
    );

    // set up the AlertDialog
    AlertDialog emptyJustification = AlertDialog(
      title: Text("Nenhuma justificativa inserida"),
      actions: [
        continueButton
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Faltas de ${widget.userInfo.name}"),
        actions: <Widget>[
          MaterialButton(
            color: Colors.orange[700],
            child: Text("Enviar", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              if(justification.isNotEmpty) {
                await setJustification();
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
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
       ),
      body: Container(
        width: 100,
        child: TextFormField(
          cursorColor: Colors.deepOrange,
          style: TextStyle(
            height: 100
          ),
          controller: TextEditingController(),
          maxLength: 350,
          onChanged: (String value) {
            justification = value;
          },
        ),
      ),
    );
  }

  Future setJustification() async {
    var firestone = Firestore.instance;
    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (studentList) async {
      if (studentList.documents.length > 0){
          await studentList.documents[0].reference.collection("students")
          .where("name", isEqualTo: widget.userInfo.name).limit(1).getDocuments()
          .then( (absencesList) async {
            await absencesList.documents[0].reference.collection("absences")
            .document(widget.absenceID)
            .updateData(
              {
                'justification': justification,
                'justified': true,
                "status": "unchecked"
              });
          });  
        }
      }
    );
  }
}