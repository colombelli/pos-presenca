
import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/*
  Essa pagina se refere a visualização das faltas da semana
  Ela aparece quando se clica em ver as faltas da semana na conta do ppg
  ! provavelmente deve ser modificada para juntar com o processamento de faltas
*/

class WeekAbsencesReview extends StatelessWidget {
  final AuthService _auth = AuthService();
  final User userInfo;
  WeekAbsencesReview({ Key key, this.userInfo}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: new AppBar(
//        leading: Icon(Icons.school),
        title: new Text("Faltas da semana"),
        backgroundColor: Colors.orange[700],
        elevation: 0.0,
//        actions: <Widget>[
//          FlatButton.icon(
//            icon: Icon(Icons.person),
//            onPressed: () async {
//              await _auth.signOut();
//            },
//            label: Text(translation('logout_button')),
//          )
//        ]
      ),
      body: WeekAbsencesList(userInfo: userInfo,),
    );
  }
}

class WeekAbsencesList extends StatefulWidget {
  final User userInfo;
  WeekAbsencesList({ Key key, this.userInfo}): super(key: key);

  @override
  _WeekAbsencesListState createState() => _WeekAbsencesListState();
}

class _WeekAbsencesListState extends State<WeekAbsencesList> {
  Future _data;

  Future getStudents() async {
    var firestone = Firestore.instance;
    QuerySnapshot  qn;

    List<DocumentSnapshot> dsl = <DocumentSnapshot>[];

    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (data) async {
      if (data.documents.length > 0){
          qn = await data.documents[0].reference.collection("students").getDocuments().then( (adat) async {
            if (adat.documents.length > 0) {
              for (var doc in adat.documents) {
                final snap = await doc.reference.collection('weekAbsences').where('date', isLessThan: Timestamp.fromDate(DateTime.now())).getDocuments();
                if ( snap.documents.length != 0 && snap.documents.length > 1) { 
                  dsl.add(doc);
                }
              }
            }
          });
        }
      }
    );
    //return qn.documents;
    return dsl;
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
            return Center(
              child: Container(
//                padding: EdgeInsets.all(8.0),
//                decoration: new BoxDecoration(
//                  borderRadius: BorderRadius.all(Radius.circular(20)),
//                  border: new Border.all(
//                    width: 1.0,
//                    color: Colors.deepOrange
//                  ),
//                 color: Colors.deepOrange
//                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.import_contacts, color: Colors.white),
                    Text(
                      "Não existem novas faltas.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
              ),
            );
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
            qn = await atad.documents[0].reference.collection('weekAbsences').orderBy('date').getDocuments();
          });
        }
      }
    );
    qn.documents.forEach((element) {
      weekAbsencesIDS.add(element.documentID);
    });
    return qn.documents;//.where((snapshot) => snapshot.data.containsValue("professor"));
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
        backgroundColor: Colors.grey[100],
        content: Text('Solicitação de justificativa enviada para ${widget.student.data['name']}', style: TextStyle(color: Colors.orange[700]),),
      ),
    );
  }

  Future transferAbsences() async {
    var firestone = Firestore.instance;

    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (data) async {
      if (data.documents.length > 0){
          await data.documents[0].reference.collection("students").where("name", isEqualTo: widget.student.data['name']).limit(1).getDocuments().then( (atad) async {
            weekAbsencesIDS.forEach((absID) {
              atad.documents[0].reference.collection('weekAbsences').document(absID).get().then((dWA) async {
                await atad.documents[0].reference.collection('absences')
                  .add(
                    {
                      "date": dWA.data["date"],
                      "justified": false,
                      "justification": ''
                    }
                  ).then((updDoc) async => await atad.documents[0].reference.collection('weekAbsences').document(absID).delete());
              });
            }
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.symmetric(vertical: 1.0),
      child: new Column(
        children: <Widget>[
          new Container(
            color: Colors.white,
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
                    new FlatButton(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.notification_important, color: Colors.orange[700]),
                          Text("Notificar", style: TextStyle(color: Colors.orange[700]),)
                        ]
                      ),
                      onPressed: () async {
                        await transferAbsences(); 
                        return _showToast(context);
                      },
                      shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                    ),  
                    new IconButton(
                      icon: new Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: new BoxDecoration(
                          color: Colors.white,
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
                      child: Loading(), 
                    ),
                  );
                } else if (snapshot.data.isNotEmpty) {
                    return ExpandableContainer(
                      expanded: expandFlag,
                      expandedHeight: snapshot.data.length*59.0,
                      child: ListView.builder(
                        itemCount: snapshot.data.length, 
                        itemBuilder: (BuildContext context, int index) {
                          return new Container(
                            decoration:
                                new BoxDecoration(border: new Border.all(width: 1.0, color: Colors.deepOrange), color: Colors.orange[100]),
                            child: new ListTile(
                              title: new Text(
                                DateFormat('yMd').format(DateTime.parse(snapshot.data[index].data['date'].toDate().toString())),
                                style: new TextStyle(color: Colors.orange[700]),
                              ),
                              leading: new Icon(
                                Icons.date_range,
                                color: Colors.orange[700],
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
                    child :Center(child: Text("Não existem novas justificativas.", style: TextStyle(color: Colors.white),),),
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