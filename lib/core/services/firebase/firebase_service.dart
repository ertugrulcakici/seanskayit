import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _firestorage = FirebaseStorage.instance;
  static final FirebaseDatabase _realtime = FirebaseDatabase.instance;

  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get firestorage => _firestorage;
  FirebaseDatabase get realtime => _realtime;
}
