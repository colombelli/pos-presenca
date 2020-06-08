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

  Future _data;

  Future getStudents() async {
    var firestone = Firestore.instance;
    QuerySnapshot qn = await firestone.collection("students").getDocuments();
    return qn.documents;//.where((snapshot) => snapshot.data.containsValue("professor"));
  }

  navigateToAbscences(DocumentSnapshot post) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AbscencesPage(post: post,)));
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
              child: Text("Loading..."),
            );
          } else {

            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (_, index){

                return ListTile(
                  title: Text(snapshot.data[index].data['name']),
                  onTap: () => navigateToAbscences(snapshot.data[index]),
                );

            });

        }

      }),
    );
  }
}


class AbscencesPage extends StatefulWidget {

  final DocumentSnapshot post;

  AbscencesPage({this.post});

  @override
  _AbscencesPageState createState() => _AbscencesPageState();
}

class _AbscencesPageState extends State<AbscencesPage> {

  Future _data;

  Future getAbscences() async {
    var firestone = Firestore.instance;
    QuerySnapshot qn = await firestone.collection("abscences").getDocuments();
    return qn.documents;//.where((snapshot) => snapshot.data.containsValue("professor"));
  }

  navigateToDetails(DocumentSnapshot post) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(post: post,)));
  }

  @override
  void initState() {
    super.initState();
    _data = getAbscences();
  }

  @override 
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.data['name']),
      ),
      body: Container(
        child: Card(
          child: ListTile(
            title: Text(widget.post.data['professor']),
          
          ),
        ),
        
      ),
    );
  }
}
 // Widget build(BuildContext context) {
 //   return Scaffold(
 //     appBar: AppBar(
 //       title: Text("oi"),
 //     ),
 //     body: Container(
 //       child: FutureBuilder(
 //         future: _data,
 //         builder: (_, snapshot) {

 //           if (snapshot.connectionState == ConnectionState.waiting) {
 //             return Center(
 //               child: Text("Loading..."),
 //             );
 //           } else {

 //             return ListView.builder(
 //               itemCount: snapshot.data.length,
 //               itemBuilder: (_, index){

 //                 return ListTile(
 //                   title: Text(snapshot.data[index].data['date'].toDate().toString()),
 //                   onTap: () => navigateToDetails(snapshot.data[index]),
 //                 );

 //             });

 //         }

 //       }),
 //   );
 // }
// }

class DetailsPage extends StatefulWidget {
  final DocumentSnapshot post;

  DetailsPage({this.post});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.data['date']),
      ),
      body: Container(
        child: Card(
          child: ListTile(
            title: Text(widget.post.data['date']),
          subtitle: Text(widget.post.data['justified']),
          
          ),
        ),
        
      ),
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