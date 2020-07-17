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
      setUser(userType, professor, prEmails[i], "");
    });
    return null;
  }

  Future<void> populateDBabsences(){
    return null;
  }
}