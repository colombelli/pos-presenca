import 'package:pg_check/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create User object out of Firebase object
  User _userFromFirebaseUser(FirebaseUser user) {

    // reading this syntax:
    // if user is not null, return new User object, else return null
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }
  
  // sign in
  Future signIn(String email, String password) async {

    try {

      AuthResult result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);

    } catch(e) {
      print(e.toString());
      return null;
    }

  } 


  // register
  Future registerEmailPassword( String email, String password, User newUser, 
                                String progID, String professor) async {

    try {

      AuthResult result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      FirebaseUser user = result.user;

      final CollectionReference postsRef = Firestore.instance.collection('users');
      final jsonUserInfo = {
        "name": newUser.name,
        "program": newUser.program,
        "type": newUser.type
      };
      await postsRef.document(user.uid).setData(jsonUserInfo);


      if (newUser.type == "professor"){
        final CollectionReference profRef = Firestore.instance.collection('programs')
                                .document(progID).collection('professors');
        await profRef.document(user.uid).setData({"name": newUser.name});
      }
      else if (newUser.type == "student"){
        final CollectionReference studRef = Firestore.instance.collection('programs')
                                .document(progID).collection('students');
        await studRef.document(user.uid).setData({"name": newUser.name, "professor": professor});
      }

      return _userFromFirebaseUser(user);

    } catch(e) {
      print(e.toString());
      return null;
    }

  }


  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e) {
      print(e.toString()); // shows error in console
      return null;
    }
  }
}