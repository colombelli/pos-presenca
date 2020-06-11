class User {

  final String uid;
  final String type;
  final String name;
  
  User({ this.uid, this.type, this.name});

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

class Professor extends User {

  final program;

  Professor({
    uid,
    type,
    name,
    this.program,
  }) : super(uid: uid, type: type, name: name);

}