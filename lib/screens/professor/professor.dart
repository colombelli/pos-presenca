import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Professor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: new AppBar(
        title: new Text("Professor page"),
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

  Future getPosts() async {
    var firestone = Firestore.instance;
    QuerySnapshot qn = await firestone.collection("students").getDocuments();

    return qn.documents;//.where(/* campo professor == nome ususario logado*/);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getPosts(),
        builder: (_, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Text("Loading..."),
            );
          } else {

            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (_, index){

                return ListTile(
                  title: Text(snapshot.data[index].data['name']),
                );

            });

        }

      }),
    );
  }
}


class AbscencesPage extends StatefulWidget {
  @override
  _AbscencesPageState createState() => _AbscencesPageState();
}

class _AbscencesPageState extends State<AbscencesPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

class DetailsPage extends StatefulWidget {
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

//for student in student:
//  if student.professor == professor:
//     //display student name in initial list
//
//    for abscence in abscences: // if student name is clicked the following happens in a new page
//      if abscence.student == student:
//        //show abscence date
//
//        if date.isClicked():
//          // show date, hour, justified, justification, etc









//      body: StreamBuilder(
//        stream: Firestore.instance.collection('students').snapshots(),
//        builder: (context, snapshot) {
//          if (!snapshot.hasData) return Text('Loading data. Please wait.');
//          return Column(
//            children: <Widget>[
//              Text(snapshot.data.documents[0]['name']),
//              Text(snapshot.data.documents[0]['professor'])
//            ],
//          );
//        },
//      )