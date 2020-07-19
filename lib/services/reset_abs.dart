import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/services/auth.dart';

class ResetAbsences {

  List<String> students = [
    "Roberta J. K.",
    "Roberta H. Q.",
    "José B.",
    "Claudia J. G.",
    "Tobias Z.",
    "Carlos J.",
    "José L.",
    "Samuel D. M.",
    "Daniela M.",
    "Alberta B.",
    "Manuela H.",
    "Mathias S.",
    "Arnaldo V.",
    "Leonardo M.",
    "João S.",
    "Aaron S.",
    "Carolina F.",
    "William B.",
    "Eduardo A.",
    "Ana S.",
    "Mateus S.",
    "Daniel C.",
    "João H.",
    "Joel L.",
    "Felipe C.",
  ];

  List<String> stEmails = [
    "roberta.keli@inf.ufrgs.br",
    "roberta.quman@inf.ufrgs.br",
    "jose.bartlet@inf.ufrgs.br",
    "claudia.gregg@inf.ufrgs.br",
    "tobias.ziegler@inf.ufrgs.br",
    "carlos.jovem@inf.ufrgs.br",
    "jose.inocente@inf.ufrgs.br",
    "samuel.mar@inf.ufrgs.br",
    "daniela.musgo@inf.ufrgs.br",
    "alberta.bartlet@inf.ufrgs.br",
    "manuela.hampton@inf.ufrgs.br",
    "mathias.santos@inf.ufrgs.br",
    "armaldo.vieira@inf.ufrgs.br",
    "leonardo.magaiver@inf.ufrgs.br",
    "joao.spencer@inf.ufrgs.br",
    "aaron.sorkin@inf.ufrgs.br",
    "carolina.fiel@inf.ufrgs.br",
    "willian.bonner@inf.ufrgs.br",
    "eduardo.alameda@inf.ufrgs.br",
    "ana.saliva@inf.ufrgs.br",
    "mateus.sal@inf.ufrgs.br",
    "daniel.conca@inf.ufrgs.br",
    "joao.vespari@inf.ufrgs.br",
    "joel.lucas@inf.ufrgs.br",
    "felipe.colombelli@inf.ufrgs.br"
  ];

  List<String> professors = [
    "Ariel S.",
    "Dulé C.",
    "Ariel S.",
    "Roberto L",
    "Ariel S.",
    "Dulé C.",
    "Dulé C.",
    "Ricardo S.",
    "Roberto L",
    "Ricardo S.",
    "Ricardo S.",
    "Ariel S.",
    "Jenice M.",
    "Jenice M.",
    "Ricardo S.",
    "Dulé C.",
    "Roberto L",
    "Ricardo S.",
    "Jenice M.",
    "Dulé C.",
    "Roberto L",
    "Roberto L",
    "Jenice M.",
    "Ricardo S.",
    "Ariel S."
  ];

  List<String> prEmails = [
    "ariel.sorkin@inf.ufrgs.br",
    "dule.costa@inf.ufrgs.br",
    "ariel.sorkin@inf.ufrgs.br",
    "roberto.lonin@inf.ufrgs.br",
    "ariel.sorkin@inf.ufrgs.br",
    "dule.costa@inf.ufrgs.br",
    "dule.costa@inf.ufrgs.br",
    "ricardo.schiff@inf.ufrgs.br",
    "roberto.lonin@inf.ufrgs.br",
    "ricardo.schiff@inf.ufrgs.br",
    "ricardo.schiff@inf.ufrgs.br",
    "ariel.sorkin@inf.ufrgs.br",
    "jenice.maloney@inf.ufrgs.br",
    "jenice.maloney@inf.ufrgs.br",
    "ricardo.schiff@inf.ufrgs.br",
    "dule.costa@inf.ufrgs.br",
    "roberto.lonin@inf.ufrgs.br",
    "ricardo.schiff@inf.ufrgs.br",
    "jenice.maloney@inf.ufrgs.br",
    "dule.costa@inf.ufrgs.br",
    "roberto.lonin@inf.ufrgs.br",
    "roberto.lonin@inf.ufrgs.br",
    "jenice.maloney@inf.ufrgs.br",
    "ricardo.schiff@inf.ufrgs.br",
    "ariel.sorkin@inf.ufrgs.br"
  ];

  final DateTime day13 = new DateTime.utc(2020, DateTime.july, 14);
  final DateTime day14 = new DateTime.utc(2020, DateTime.july, 15);
  final DateTime day15 = new DateTime.utc(2020, DateTime.july, 16);
  final DateTime day16 = new DateTime.utc(2020, DateTime.july, 17);
  final DateTime day17 = new DateTime.utc(2020, DateTime.july, 18);
  final DateTime day21 = new DateTime.utc(2020, DateTime.july, 21);
  final DateTime day22 = new DateTime.utc(2020, DateTime.july, 22);
  final DateTime day23 = new DateTime.utc(2020, DateTime.july, 23);
  final DateTime day24 = new DateTime.utc(2020, DateTime.july, 24);
  final DateTime day25 = new DateTime.utc(2020, DateTime.july, 25);

  List<String> a13 = [
    "Felipe C.", "Manuela H.", "Tobias Z."
  ];
  List<String> a14 = [
    "Felipe C.", "Roberta J. K.", "Tobias Z.",  "Daniela M.", "Mateus S."
  ];
  List<String> a15 = [
    "Felipe C.", "Daniela M.", "João S.", "Mateus S."
  ];
  List<String> a16 = [
    "Felipe C.", "Carolina F.", "Roberta H. Q."
  ];
  List<String> a17 = [
    "Felipe C.", "Carolina F.", "Joel L.", "João S."
  ];
 
  final AuthService auth = AuthService();


  void setUser(userType, name, email, professor) async {
    String programName = "PPGC";
    String programID = "8TRUasflYDMqJ1AFYpLKMo9eUVb2";
    String password = "123456";

    User newUser = User(uid: "willNotBeUsed", type: userType, name: name, 
                      program: programName);

    dynamic results = await auth
      .registerEmailPassword( email, password, newUser, 
                              programID, professor);

    if(results == null){
      print("ERROR IN THE USER CREATION");
    }
  }


  Future<void> populateDBUsers() {
    
    var userType = "student";
    students.asMap().forEach((i, student) {
      print("Setting student: "+student);
      setUser(userType, student, stEmails[i], professors[i]);
    });

    userType = "professor";
    professors.asMap().forEach((i, professor) { 
      print("Trying to set professor: "+professor);
      try{
        setUser(userType, professor, prEmails[i], "");
      }catch(e){
        print("Already added.");
      }
    });
    return null;
  }


  void setAbsence(ref, name, date, documentID) async{

    await ref.where("name", isEqualTo: name).getDocuments().then((qsn) {
        String docID = qsn.documents.first.documentID;
        ref.document(docID).collection("weekAbsences").document(documentID).setData({"date": date, "justification": "", "justified": false});
      });
    
    return;
  }


  Future<void> populateDBabsences() async{
    
    final List abs = [a13,a14,a15,a16,a17,a13,a13,a13,a13,a13];
    final List dates = [day13,day14,day15,day16,day17,day21,day22,day23,day24,day25];

    final CollectionReference stRef = Firestore.instance.collection('programs')
                            .document("8TRUasflYDMqJ1AFYpLKMo9eUVb2").collection('students');
    
    abs.asMap().forEach((i, absents) {

      absents.forEach((stName){
        var genDocID = stName+i.toString();
        setAbsence(stRef, stName, dates[i], genDocID);
      });
    });

    return null;
  }
}