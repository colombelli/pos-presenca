import 'package:flutter/material.dart';
import 'package:pg_check/models/program.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/services/database.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/shared/loading.dart';

class ProfessorDrop extends StatefulWidget {
  
  final typeOfUser;
  final Function callbackNewProfessor;
  final Program selectedProgram;
  final User selectedProfessor;
  ProfessorDrop({Key key, @required this.typeOfUser,
                          @required this.callbackNewProfessor, 
                          @required this.selectedProgram,
                          @required this.selectedProfessor }) : super(key: key);

  @override
  _ProfessorDropState createState() => _ProfessorDropState();
}

class _ProfessorDropState extends State<ProfessorDrop> {

  bool loading = true;
  User selectedProfessor;
  
  List<DropdownMenuItem<User>> availableProfessors;
  List<DropdownMenuItem<User>> buildDropdownMenuItems(List professors){

    List<DropdownMenuItem<User>> items = List();
    for (User professor in professors) {
      items.add(
        DropdownMenuItem(
          value: professor, 
          child: new Text(professor.name)//, style: TextStyle(color: Colors.orange[700]),)
        )
      );
    }
    return items;
  }

  dbWrapper() async {
    final progUid = widget.selectedProgram.uid;
    final programFireBase = await DatabaseService().programsCollection.document(progUid).collection("professors").getDocuments();
    
    final List<User> professors = [];

    if(programFireBase == null){
      //error!
      print("error");
    } else {

      for (var doc in programFireBase.documents) {
        professors.add(User(uid: doc.documentID, type: "professor", 
                            name: doc.data["name"], program: widget.selectedProgram.name));
      }
      availableProfessors = buildDropdownMenuItems(professors);

      setState(() {
        loading = false;
      });
    } 
  }


  @override
  void didUpdateWidget (ProfessorDrop oldWidget) {
    if (selectedProfessor != widget.selectedProfessor) {
      
      setState(() {
        selectedProfessor = widget.selectedProfessor;
      });

    }
    super.didUpdateWidget(oldWidget);
  }
  

  @override
  Widget build(BuildContext context) {
    
    final translation = (String s) => AppLocalizations.of(context).translate(s);
    
    dbWrapper();

    print("sel prof");
    print(selectedProfessor);

    if (widget.typeOfUser == "student") {
      return loading ? Loading() : Column(
        children: <Widget>[
          SizedBox(height: 20.0),
          DropdownButton(
            value: selectedProfessor,
            items: availableProfessors,
            hint: Text(translation("professor_hint")),
            onChanged: (User selected) {
              widget.callbackNewProfessor(selected);
          },
          ),
          SizedBox(height: 20.0)
        ],
      );
    }
    else {
      return SizedBox(height: 20.0);
    }
  }
}