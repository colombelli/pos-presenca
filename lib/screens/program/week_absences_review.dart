
import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/models/user.dart';
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

  Future getStudents() async { // gets all students (yeah a lot more data than necssary sue me)
    var firestone = Firestore.instance;
    QuerySnapshot  qn;

    await firestone.collection("programs").where("name", isEqualTo: "PPGC").limit(1).getDocuments().then( (data) async { //! Muda query de programa
      if (data.documents.length > 0){
          await data.documents[0].reference.collection("students").getDocuments();
        }
    });

    return qn.documents;//.where((snapshot) => snapshot.data.containsValue("professor"));
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
          } else if (snapshot.data.isNotEmpty) {
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return new ExpandableListView(
                  student: "Title $index",
                  daysAbsent: snapshot.data['weekAbsences'],
                );
              },
              itemCount: 5,
            );
          } else {
            return Center(child: Text("Não existem faltas registradas nesta semana."),);
          }
        }
      ),
    );
  }
}

class ExpandableListView extends StatefulWidget {
  final String student;
  final String daysAbsent;

  const ExpandableListView({Key key, this.student, this.daysAbsent}) : super(key: key);

  @override
  _ExpandableListViewState createState() => new _ExpandableListViewState();
}

class _ExpandableListViewState extends State<ExpandableListView> {
  bool expandFlag = false;

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
                          size: 30.0,
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        expandFlag = !expandFlag;
                      });
                    }),
                new Text(
                  widget.title,
                  style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                )
              ],
            ),
          ),
          new ExpandableContainer(
              expanded: expandFlag,
              child: new ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return new Container(
                    decoration:
                        new BoxDecoration(border: new Border.all(width: 1.0, color: Colors.grey), color: Colors.black),
                    child: new ListTile(
                      title: new Text(
                        "Cool $index",
                        style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      leading: new Icon(
                        Icons.local_pizza,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                itemCount: 15,
              ))
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
    this.expandedHeight = 300.0,
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