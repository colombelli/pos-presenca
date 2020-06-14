import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pg_check/models/user.dart';
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
  final User userInfo;
  History({ Key key, this.userInfo}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final translation = (String s) => AppLocalizations.of(context).translate(s);

    return PreviousAbsences(userInfo: userInfo);//Scaffold(
//      appBar: new AppBar(
//        title: new Text("Suas faltas"),
//        backgroundColor: Colors.blue[400],
//        elevation: 0.0,
//        actions: <Widget>[
//          FlatButton.icon(
//            icon: Icon(Icons.person),
//            onPressed: () async {
//              await _auth.signOut();
//            },
//            label: Text(translation('logout_button')),
//          )
//        ]
//      ),
//
//      body: PreviousAbsences(userInfo: userInfo),
//    );
  }
}
class PreviousAbsences extends StatefulWidget {
  final User userInfo;
  PreviousAbsences({ Key key, this.userInfo}): super(key: key);
  @override

  _PreviousAbsencesState createState() => _PreviousAbsencesState();
}

class _PreviousAbsencesState extends State<PreviousAbsences> {

  Future _data;
  EventList<Event> _markedDateMap = new EventList<Event>();
  bool _isInitialized;
  DateTime _currentDate;
  static String noAbsenceText = "Você não faltou neste dia";
  static String futureDayText = "Esse dia ainda não foi registrado";
  String calendarText = noAbsenceText;

  Future getAbsences() async {
    String abCollection = "absences";
    var firestone = Firestore.instance;
    QuerySnapshot  qn;

    await firestone.collection("programs").where("name", isEqualTo: widget.userInfo.program).limit(1).getDocuments().then( (data) async {
      if (data.documents.length > 0){
          await data.documents[0].reference.collection("students").where("name", isEqualTo: widget.userInfo.name).limit(1).getDocuments().then( (atad) async { // ! Mudar para pesquisar pelo nome do usuario
            qn = await atad.documents[0].reference.collection(abCollection).orderBy('date').getDocuments();                                      // ! quando integrar com a página de usuário
          });
        }
      }
    );

    return qn.documents;
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
          title: snapshot.data[i].data['justified']
            ? 'Falta justificada: ' +  snapshot.data[i].data['justification']
            : "Falta não justificada",
          icon: _eventIcon,
        )
      );
    }
  }

  @override
  void initState() {
    _data = getAbsences();
    _isInitialized = false;

    super.initState();
  }

  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  void refresh(DateTime date) {
    print('selected date ' + date.day.toString() + date.month.toString() + date.year.toString() + ' ' + date.toString());
    if(_markedDateMap.getEvents(new DateTime(date.year, date.month, date.day)).isNotEmpty){
      calendarText = _markedDateMap
          .getEvents(new DateTime(date.year, date.month, date.day))[0]
          .title;
    } else if(weekNumber(date) < weekNumber(DateTime.now())){
      calendarText = noAbsenceText; 
    } else{
      calendarText = futureDayText;
    }

    _currentDate = date;
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
          } else{
              if (_isInitialized == false) {
                createAbsenceEvents(snapshot);
                _isInitialized = true;
              }
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Card(
                      child: CalendarCarousel(
                        selectedDateTime: _currentDate,
                        markedDatesMap: _markedDateMap,
                        weekFormat: false,
                        height: 350.0,
                        showHeader: true,
                        daysHaveCircularBorder: true,
                        locale: 'pt',
                        selectedDayButtonColor: Colors.blue[100], 
                        selectedDayBorderColor: Colors.transparent,
                        todayBorderColor: Colors.transparent,
                        todayButtonColor: Colors.white,
                        todayTextStyle: TextStyle(color: Colors.red[900]),
                        weekdayTextStyle: TextStyle(color: Colors.black),
                        weekendTextStyle: TextStyle( color: Colors.red),
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
                            )
                          )
                        )
                      )
                    )
                  ]
                )
              );
          }
        }
      ),
    );
  }
}