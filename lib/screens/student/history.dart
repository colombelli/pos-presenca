import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';

/*
  Essa página se refere ao histórico de faltas do aluno
  Ela aparece quando, a partir do menu de um aluno logado, ele clica em visualizar histórico
*/

class History extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return Scaffold(
      appBar: new AppBar(
//        leading: Icon(Icons.school),
        title: new Text("Suas faltas"),
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

      body: PreviousAbsences(),
    );
  }
}
class PreviousAbsences extends StatefulWidget {
  @override
  _PreviousAbsencesState createState() => _PreviousAbsencesState();
}

class _PreviousAbsencesState extends State<PreviousAbsences> {

  Future _data;
  EventList<Event> _markedDateMap = new EventList<Event>();

  static String noEventText = "Você não faltou neste dia.";
  String calendarText = noEventText;

  Future getAbsences() async {
    var firestone = Firestore.instance;
    QuerySnapshot  qn;

    await firestone.collection("programs").where("name", isEqualTo: "PPGC").limit(1).getDocuments().then( (data) async {
      if (data.documents.length > 0){
          await data.documents[0].reference.collection("students").where("name", isEqualTo: "cica").limit(1).getDocuments().then( (atad) async {
            qn = await atad.documents[0].reference.collection('absences').orderBy('date').getDocuments();
          });
        }
      }
    );

    return qn.documents;//.where((snapshot) => snapshot.data.containsValue("professor"));
  }

  static Widget _eventIcon = new Container(
    decoration: new BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(1000)),
        border: Border.all(color: Colors.blue, width: 2.0)),
    child: new Icon(
      Icons.person,
      color: Colors.amber,
    ),
  );

  void createAbsenceEvents(snapshot) {
    // cria faltas
    for (int i=0; i < snapshot.data.length; i++) {
      _markedDateMap.add(
        DateTime.parse(snapshot.data[i].data['date'].toDate().toString()),
        new Event(
          date: DateTime.parse(snapshot.data[i].data['date'].toDate().toString()),
          title: snapshot.data[i].data['justified'] ? 'Falta justificada' : "Falta não justificada",
          icon: _eventIcon,
        )
      );
    }
  }

  @override
  void initState() {
    _data = getAbsences();

    _markedDateMap.add(
      new DateTime(2020, 5, 10),
      new Event(
        date: new DateTime(2019, 5, 10),
        title: 'Falta não justificada',
        icon: _eventIcon,
      )
    );

    super.initState();
  }

  void refresh(DateTime date) {
    print('selected date ' + date.day.toString() + date.month.toString() + date.year.toString() + ' ' + date.toString());
    if(_markedDateMap.getEvents(new DateTime(date.year, date.month, date.day)).isNotEmpty){
      calendarText = _markedDateMap
          .getEvents(new DateTime(date.year, date.month, date.day))[0]
          .title;
    } else{
      calendarText = noEventText;
    }
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
              createAbsenceEvents(snapshot);
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Card(
                      child: CalendarCarousel(
                        weekendTextStyle: TextStyle(
                          color: Colors.red,
                        ),
                        weekFormat: false,
                        selectedDayBorderColor: Colors.green,
                        markedDatesMap: _markedDateMap,
                        selectedDayButtonColor: Colors.blue[300],
                        selectedDayTextStyle: TextStyle(color: Colors.green),
                        todayBorderColor: Colors.transparent,
                        weekdayTextStyle: TextStyle(color: Colors.black),
                        height: 350.0,
                        showHeader: true,
                        daysHaveCircularBorder: true,
                        todayButtonColor: Colors.blue[100],
                        locale: 'pt',
                        onDayPressed: (DateTime date, List<Event> events) {
                           this.setState(() => refresh(date));
                        },
                      )
                    ),
                    Card(
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                          child: Center(
                            child: Text(
                              calendarText,
//                              style: Constants.textStyleCommonText,
                            )
                          )
                        )
                      )
                    )
                  ]
                )
              );
          } else {
              //return Center(child: Text("There are no registered absences for that student"),);
              return Center(child: Text("Não existem faltas registradas no seu histórico."),);
          }
        }
      ),
    );
  }
}