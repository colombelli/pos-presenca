import 'package:pg_check/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';


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


  // register


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