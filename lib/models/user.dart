class User {

  final String uid;
  final String type;
  final String name;
  final String program;
  
  User({ this.uid, this.type, this.name, this.program});

}


class Student extends User {

  final program;
  final professor;

  Student({
    uid,
    type,
    name,
    this.program,
    this.professor
  }) : super(uid: uid, type: type, name: name);

}

