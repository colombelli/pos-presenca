import 'package:flutter/material.dart';
import 'package:pg_check/models/program.dart';

class ProgramList extends StatefulWidget {
  
  List<DropdownMenuItem<Program>> availablePrograms;
  final Function notifyParent;
  final Program selectedProgram;
  ProgramList({Key key, @required this.availablePrograms, 
                        @required this.notifyParent, 
                        this.selectedProgram}) : super(key: key);

  @override
  _ProgramListState createState() => _ProgramListState();
}

class _ProgramListState extends State<ProgramList> {

  Program selected;

  @override
  void initState() { 
    super.initState();
    selected = widget.availablePrograms[0].value;
  }

  @override
  Widget build(BuildContext context) {
    
    return DropdownButton(
      value: selected,
      items: widget.availablePrograms,
      onChanged: (Program selected) {
        widget.notifyParent(selected);
      },
    );
  }
}