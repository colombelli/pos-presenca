import 'package:flutter/material.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/* pega faltas da coleção absences do aluno que não tenham justificativa, ele seleciona a que quiser e
insere seu motivo */

class JustificationsReview extends StatelessWidget {
  final AuthService _auth = AuthService();
  final User userInfo;
  JustificationsReview({ Key key, this.userInfo}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: new AppBar(
//        leading: Icon(Icons.school),
        title: new Text("Justificativas"),
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
      body: JustificationsList(userInfo: userInfo,),
    );
  }
}

class JustificationsList extends StatefulWidget {
  final User userInfo;
  JustificationsList({ Key key, this.userInfo}): super(key: key);

  @override
  _JustificationsListState createState() => _JustificationsListState();
}

class _JustificationsListState extends State<JustificationsList> {
  Future _data;

  Future getUncheckedStudents() async {
    var firestone = Firestore.instance;
    List<DocumentSnapshot> uncheckedStudents = new List();
    /* ta feio, mas o que isso faz é: pega todos os estudantes de um programa, 
    vê se cada um tem justificativas inseridas e vê o status
    delas, e se tiver unchecked, ele faz a volta e devolve o estudante, 
    e no fim tu tem uma lista de todos os estudantes com justificativa pendente */
    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (programCollections) async {
      if (programCollections.documents.length > 0){
        await programCollections.documents[0].reference.collection("students").getDocuments().then( (students) {
          if(students.documents.length > 0) {
            students.documents.forEach((student) async {
              await student.reference.collection('absences').orderBy('date', descending: true).getDocuments().then((qnA) {
                List<DocumentSnapshot> studentHasUncheckedJustifications =
                  qnA.documents.where((element) => element.data["justified"] == true && element.data["status"] == 'unchecked').toList();
                if (studentHasUncheckedJustifications.length > 0) {
                  uncheckedStudents.add(student);
                }
              });
            });
          }
        });
      }
    });
    print(uncheckedStudents.length); 
    return uncheckedStudents;
  }

  @override
  void initState() {
    super.initState();
    _data = getUncheckedStudents();
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
          } else if (snapshot.data.isNotEmpty) {
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return new ExpandableListView(
                  student: snapshot.data[index],
                  userInfo: widget.userInfo,
                );
              },
              itemCount: snapshot.data.length,
            );
          } else {
            return Center(child: Text("Não existem novas justificativas."),);
          }
        }
      ),
    );
  }
}

class ExpandableListView extends StatefulWidget {
  final DocumentSnapshot student;
  final User userInfo;

  const ExpandableListView({Key key, this.student, this.userInfo}) : super(key: key);

  @override
  _ExpandableListViewState createState() => new _ExpandableListViewState();
}

class _ExpandableListViewState extends State<ExpandableListView> {
  bool expandFlag = false;
  Future _data;
  List weekAbsencesIDS = new List();

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

  navigateToJustificationDetails(student, absence, userInfo) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => JustificationDetails(student: student, absence: absence, userInfo: userInfo,)));
  }


  @override
  void initState() {
    super.initState();
    _data = getAbsences();
  }

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('Justificativa de ${widget.student.data['name']} foi respondida.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.symmetric(vertical: 1.0),
      child: new Column(
        children: <Widget>[
          new Container(
            color: Colors.blue[50],
            padding: new EdgeInsets.symmetric(horizontal: 5.0),
            child: new Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                new Icon(
                  Icons.person,
                ),
                new Text(
                  "    ${widget.student.data['name']}",
                  style: new TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    new IconButton(
                      icon: new Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: new BoxDecoration(
                          color: Colors.blue[250],
                          shape: BoxShape.circle,
                        ),
                        child: new Center(
                          child: new Icon(
                            expandFlag ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.blue[400],
                            size: 27.0,
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          expandFlag = !expandFlag;
                        });
                      }
                    ),
                  ],
                ),
              ],
            ),
          ),
          new FutureBuilder(
              future: _data,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ExpandableContainer(
                    expanded: expandFlag,
                    expandedHeight: 69,
                    child: Center(
                      child: CircularProgressIndicator(), 
                    ),
                  );
                } else if (snapshot.data.isNotEmpty) {
                    return ExpandableContainer(
                      expanded: expandFlag,
                      expandedHeight: snapshot.data.length*58.0,
                      child: ListView.builder(
                        itemCount: snapshot.data.length, 
                        itemBuilder: (BuildContext context, int index) {
                          return new Container(
                            decoration:
                                new BoxDecoration(border: new Border.all(width: 1.0, color: Colors.grey), color: Colors.blue[50]),
                            child: new ListTile(
                              leading: new Icon(
                                Icons.date_range,
                                color: Colors.grey[900],
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    DateFormat('yMd').format(DateTime.parse(snapshot.data[index].data['date'].toDate().toString())),
                                    style: new TextStyle(color: Colors.black),
                                  ),
                                new FlatButton(
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    children: <Widget>[
//                                      Icon(Icons.visibility), // ! Decidir com/sem icon
                                      Text(
                                        "  Visualizar",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )
                                    ]
                                  ),
                                  onPressed: () async {
                                    navigateToJustificationDetails(widget.student, snapshot.data[index], widget.userInfo);
                                    //return _showToast(context);
                                  },
                                  shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                                ),  
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                } else { 
                  return ExpandableContainer( 
                    expanded: expandFlag,
                    expandedHeight: 69.0,
                    child :Center(child: Text("Não existem novas justificativas."),),
                  );
                }
              }
            ),
        ],
      ),
    );
  }
}

class ExpandableContainer extends StatelessWidget {
  final bool expanded;
  final double collapsedHeight;
  final double expandedHeight;
  final Widget child;

  ExpandableContainer({
    @required this.child,
    this.collapsedHeight = 0.0,
    this.expandedHeight = 918.0,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return new AnimatedContainer(
      duration: new Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: screenWidth,
      height: expanded ? expandedHeight : collapsedHeight,
      child: new Container(
        child: child,
        decoration: new BoxDecoration(border: new Border.all(width: 1.0, color: Colors.blue)),
      ),
    );
  }
}

class JustificationDetails extends StatefulWidget {
  final DocumentSnapshot absence;
  final DocumentSnapshot student;
  final User userInfo;
  JustificationDetails({ this.absence, this.student, key, this.userInfo}): super(key: key);

  @override
  _JustificationDetailsState createState() => _JustificationDetailsState();
}
class _JustificationDetailsState extends State<JustificationDetails> {

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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton(
                child: Text("Rejeitar"),
                onPressed:  () {
                  changeJustificationStatus("rejected");
                  Navigator.pop(context);
                  Navigator.pop(context);
                },                
              ),
              RaisedButton(
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