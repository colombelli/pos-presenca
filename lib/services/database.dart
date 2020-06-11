import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid });

  final CollectionReference userCollection = Firestore.instance.collection('users');
  final CollectionReference programsCollection = Firestore.instance.collection('programs');
  
  Stream<QuerySnapshot> get programs {
    return programsCollection.snapshots();
  }


}