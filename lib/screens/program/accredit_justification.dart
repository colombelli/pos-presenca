import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pg_check/shared/loading.dart';

/* pega faltas da coleção absences do aluno que não tenham justificativa, ele seleciona a que quiser e
insere seu motivo */
String formatDays(List days) {
  String formattedDays = DateFormat('d/M/y').format( DateTime.parse(days[days.length-1].data['date'].toDate().toString()));
  for(int i = days.length-2; i >= 0; i--) {
    formattedDays += ',  ' + DateFormat('d/M/y').format( DateTime.parse(days[i].data['date'].toDate().toString()));
  }
  return formattedDays;
}

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
        backgroundColor: Colors.orange[700],
        elevation: 0.0,
        
      ),
      body: 
      JustificationsList(userInfo: userInfo,),
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
      color: Colors.orange[700],
      child: FutureBuilder(
        future: _data,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Loading(), //Text("Loading..."),
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
            return Center(child: Text("Não existem novas justificativas.", 
                style: TextStyle(color: Colors.white),),);
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

    int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  Future getAbsences() async {
    var firestone = Firestore.instance;
    QuerySnapshot  qn;
    Map absencesPerWeek = new Map();
    List uncheckedAbsences;

    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (data) async {
      if (data.documents.length > 0){
          await data.documents[0].reference.collection("students").where("name", isEqualTo: widget.student.data['name']).limit(1).getDocuments().then( (atad) async {
            qn = await atad.documents[0].reference.collection('absences').orderBy('date').getDocuments();
          });
        }
      }
    );
    uncheckedAbsences = qn.documents.where((element) => element.data['status'] == 'unchecked').toList();
    uncheckedAbsences.forEach((unchAbsenceDay) {
      int weekNumber = getWeekNumber(DateTime.parse(unchAbsenceDay.data["date"].toDate().toString()));
      List absencesOnWeek = absencesPerWeek.containsKey(weekNumber) ? absencesPerWeek[weekNumber] : new List();
      absencesOnWeek.add(unchAbsenceDay);
      absencesPerWeek[weekNumber] = absencesOnWeek; 
    });
    return absencesPerWeek;
  }

  navigateToJustificationDetails(student, absences, userInfo) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => JustificationDetails(student: student, absences: absences, userInfo: userInfo,)));
  }


  @override
  void initState() {
    super.initState();
    _data = getAbsences();
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
                  color: Colors.orange[700],
                ),
                new Text(
                  "    ${widget.student.data['name']}",
                  style: new TextStyle(fontSize: 17, color: Colors.orange[700]),
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
                            color: Colors.orange[700],
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
                          List keys = snapshot.data.keys.toList();
                          return new Container(
                            decoration:
                                new BoxDecoration(border: new Border.all(width: 1.0, color: Colors.deepOrange), color: Colors.orange[100]),
                            child: new ListTile(
                              leading: new Icon(
                                Icons.date_range,
                                color: Colors.orange[700],
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                new Flexible(
                                  child: Text(
                                    formatDays(snapshot.data[keys[index]]),
                                    style: TextStyle(color: Colors.orange[700]),
                                    overflow: TextOverflow.visible
                                    ),
                                ),
                                  new FlatButton(
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      children: <Widget>[
  //                                      Icon(Icons.visibility), // ! Decidir com/sem icon
                                        Text(
                                          "  Visualizar",
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[700]),
                                        )
                                      ]
                                    ),
                                    onPressed: () async {
                                      navigateToJustificationDetails(widget.student, snapshot.data[keys[index]], widget.userInfo);
                                      //return _showToast(context);
                                    },
                                    shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                                  ),  
                                  ],
                                ),
                            )
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
        decoration: new BoxDecoration(border: new Border.all(width: 1.0, color: Colors.deepOrange)),
      ),
    );
  }
}

class JustificationDetails extends StatefulWidget {
  final List absences;
  final DocumentSnapshot student;
  final User userInfo;
  JustificationDetails({ this.absences, this.student, key, this.userInfo}): super(key: key);

  @override
  _JustificationDetailsState createState() => _JustificationDetailsState();
}
class _JustificationDetailsState extends State<JustificationDetails> {

  void _showToast(BuildContext context, bool accepted) {
    final scaffold = Scaffold.of(context);
    final String action = accepted ? "aceita" : "rejeitada";
    scaffold.showSnackBar(
      SnackBar(
        content: Text('Justificativa de ${widget.student.data['name']} foi $action.'),
      ),
    );
  }

  final globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.orange[700],
        title: Text(formatDays(widget.absences)),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        color: Colors.orange[700],
        child:
        Card(
          child:
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget> [
          Card(
            child: ListTile(
              leading: Icon(widget.absences[0].data['justified'] ? Icons.message: Icons.speaker_notes_off, color: Colors.orange[700]),
              title: Text("Justificativa:", style: TextStyle(color: Colors.orange[700]),),
              subtitle: Text(widget.absences[0].data['justification']),
            ),
          ),
          SizedBox(height: 20,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              
              RaisedButton(
                elevation: 6,
                child: Text("Rejeitar", style: TextStyle(color:Colors.white),),
                color: Colors.deepOrange,
                onPressed:  () {
                  changeJustificationStatus("rejected");
                  Fluttertoast.showToast(
                    msg: "Justificativa de ${widget.student.data['name']} foi rejeitada.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.orange[500],
                    textColor: Colors.white,
                    fontSize: 12.0
                  );
//                  globalKey.currentState.showSnackBar(SnackBar(content: Text("text")));
//                  _showToast(context, false);
                  Navigator.pop(context);
                },                
              ),
              RaisedButton(
                elevation: 6,
                child: Text("Aceitar", style: TextStyle(color:Colors.white),),
                color: Colors.deepOrange,
                onPressed:  () {
                  changeJustificationStatus("accredited");
                  Fluttertoast.showToast(msg: "Justificativa de ${widget.student.data['name']} foi aceita.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.orange[500],
                    textColor: Colors.white,
                    fontSize: 12.0,
                  );
                  //                  _showToast(context, true);
                  Navigator.pop(context);
                },                 
              ),
            ],
          ),
          
        ]
      )),
      )
    );
  }



    Future changeJustificationStatus( String newStatus ) async {
    var firestone = Firestore.instance;
    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (studentList) async {
      if (studentList.documents.length > 0){
          await studentList.documents[0].reference.collection("students")
          .where("name", isEqualTo: widget.student.data['name']).limit(1).getDocuments()
          .then( (studColl) {
            widget.absences.forEach((absence) async {
              await studColl.documents[0].reference.collection("absences")
              .document(absence.documentID)
              .updateData(
                {
                  "status": newStatus
                }
              );
            });
          });  
        }
      }
    ); 
  }
}