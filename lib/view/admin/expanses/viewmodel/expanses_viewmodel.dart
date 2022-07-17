import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seanskayit/core/services/firebase/auth_service.dart';
import 'package:seanskayit/core/services/firebase/firebase_service.dart';
import 'package:seanskayit/core/utils/ui/popup.dart';
import 'package:seanskayit/product/models/category_model.dart';
import 'package:seanskayit/product/models/expanse_model.dart';
import 'package:seanskayit/product/models/user_model.dart';

class ExpanseViewModel extends ChangeNotifier with FirebaseService {
  List<ExpanseModel> expanses = [];
  List<CategoryModel> categories = [];
  List<CategoryModel> filteredCategories = [];
  List<UserModel> users = [];

  final Duration _duration = const Duration(milliseconds: 300);

  num get total => expanses.fold<num>(
      0, (previousValue, element) => previousValue + element.amount);

  Future fillExpanses(String date) async {
    expanses.clear();
    QuerySnapshot snapshot = await firestore
        .collection("expanses")
        .where("date", isEqualTo: date)
        .get();
    for (var element in snapshot.docs) {
      expanses
          .add(ExpanseModel.fromJson(element.data() as Map<String, dynamic>));
    }
    Future.delayed(_duration, () {
      notifyListeners();
    });
  }

  Future fillCategories() async {
    categories.clear();
    QuerySnapshot snapshot =
        await firestore.collection("expanse_categories").get();
    categories = snapshot.docs
        .map(
            (doc) => CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    filteredCategories.addAll(categories);
    Future.delayed(_duration, () {
      notifyListeners();
    });
  }

  Future fillUsers() async {
    users.clear();
    QuerySnapshot snapshot = await firestore.collection("users").get();
    users = snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<bool> addExpanse(
      {required double amount,
      required String categoryId,
      required String date}) async {
    try {
      String id = firestore.collection("expanses").doc().id;
      if (categoryId.isEmpty) return false;
      ExpanseModel model = ExpanseModel(
          addedBy: AuthService.instance.currentUser.id,
          id: id,
          amount: amount,
          categoryId: categoryId,
          date: date);
      firestore.collection("expanses").doc(id).set(model.toJson());
      Future.delayed(_duration, () {
        notifyListeners();
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> addCategory(String name) async {
    if (name.isEmpty) return null;
    try {
      if ((await firestore
              .collection("expanse_categories")
              .where("name", isEqualTo: name)
              .get())
          .docs
          .isNotEmpty) {
        return null;
      }
      String id = firestore.collection("expanse_categories").doc().id;
      CategoryModel category = CategoryModel(id: id, name: name);
      firestore.collection("expanse_categories").doc(id).set(category.toJson());
      await fillCategories();
      return id;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCategoryId(String name) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection("expanse_categories")
          .where("name", isEqualTo: name)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void onChanged(String value) {
    filteredCategories.clear();
    filteredCategories = categories
        .where((element) =>
            element.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future deleteExpanse(ExpanseModel model) async {
    try {
      await firestore.collection("expanses").doc(model.id).delete();
      expanses.removeWhere((element) => element.id == model.id);
      PopupHelper.showSimpleSnackbar("Gider silindi");
      await fillExpanses(model.date);
    } catch (e) {
      PopupHelper.showSimpleSnackbar("Gider silinemedi", error: true);
    }
  }
}
