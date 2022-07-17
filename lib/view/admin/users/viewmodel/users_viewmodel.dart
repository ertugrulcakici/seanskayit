import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:seanskayit/core/services/firebase/firebase_service.dart';
import 'package:seanskayit/product/models/user_model.dart';

class UserViewModel extends ChangeNotifier with FirebaseService {
  List<UserModel> users = [];

  final Duration _duration = const Duration(milliseconds: 500);

  Future fillUsers() async {
    QuerySnapshot snapshot = await firestore.collection("users").get();
    users = snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    Future.delayed(_duration, () {
      notifyListeners();
    });
  }

  Future<bool> addUser(Map<String, dynamic> data) async {
    try {
      String id = firestore.collection("users").doc().id;
      data["id"] = id;
      UserModel user = UserModel.fromJson(data);
      firestore.collection("users").doc(id).set(user.toJson());
      users.add(user);
      Future.delayed(_duration, () {
        notifyListeners();
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editUser(Map<String, dynamic> data) async {
    try {
      UserModel model = UserModel.fromJson(data);
      firestore.collection("users").doc(model.id).set(model.toJson());
      users = users.map((e) {
        if (e.id == model.id) {
          return model;
        }
        return e;
      }).toList();
      Future.delayed(_duration, () {
        notifyListeners();
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
