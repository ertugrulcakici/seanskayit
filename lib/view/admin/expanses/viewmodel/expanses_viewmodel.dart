import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:seanskayit/core/services/firebase/auth_service.dart';
import 'package:seanskayit/core/services/firebase/firebase_service.dart';
import 'package:seanskayit/core/utils/extentions/datetime_extentions.dart';
import 'package:seanskayit/core/utils/ui/popup.dart';
import 'package:seanskayit/product/models/category_model.dart';
import 'package:seanskayit/product/models/expanse_model.dart';
import 'package:seanskayit/product/models/user_model.dart';

class ExpanseViewModel extends ChangeNotifier with FirebaseService {
  List<ExpanseModel> expanses = [];
  List<CategoryModel> categories = [];
  List<CategoryModel> filteredCategories = [];
  List<UserModel> users = [];

  String _date = DateTime.now().toD();
  String get date => _date;
  set date(String value) {
    _date = value;
    notifyListeners();
  }

  final Duration _duration = const Duration(milliseconds: 300);

  num get total => expanses.fold<num>(
      0, (previousValue, element) => previousValue + element.amount);

  Future fillExpanses() async {
    // realtime done
    log("fill expanses");
    expanses.clear();

    String day = date.split("/")[0];
    String month = date.split("/")[1];
    String year = date.split("/")[2];

    realtime.ref("expanses/$year/$month/$day").get().then((snapshot) {
      for (var element in snapshot.children) {
        if (element.value.runtimeType != 0.runtimeType) {
          ExpanseModel expanse =
              ExpanseModel.fromJson(element.value as Map<String, dynamic>);
          expanses.add(expanse);
        }
      }
      Future.delayed(_duration, () {
        notifyListeners();
      });
    });
  }

  Future fillCategories() async {
    // realtime done
    categories.clear();
    DataSnapshot snapshot = await realtime.ref("expanse_categories").get();
    categories = snapshot.children
        .map((e) => CategoryModel.fromJson(e.value as Map<String, dynamic>))
        .toList();
    filteredCategories.addAll(categories);
    Future.delayed(_duration, () {
      notifyListeners();
    });
  }

  Future fillUsers() async {
    // realtime done
    users.clear();
    DataSnapshot snapshot = await realtime.ref("users").get();
    users = snapshot.children
        .map((e) => UserModel.fromJson(e.value as Map<String, dynamic>))
        .toList();
  }

  Future<bool> addExpanse(
      // realtime done
      {required double amount,
      required String categoryId}) async {
    try {
      log("1");
      if (categoryId.isEmpty) return false;
      log("2");
      String day = date.split("/")[0];
      String month = date.split("/")[1];
      String year = date.split("/")[2];
      log("3");
      DatabaseReference old = realtime.ref("expanses/$year/$month/$day");
      log("4");

      DataSnapshot data = await old.get();
      log("data: ${data.value}");
      if (data.value != null) {
        for (var element in data.children) {
          log("element:${element.value}");
          if (element.value is! int &&
              (element.value! as Map)["categoryId"] == categoryId) {
            log("hata");
            ExpanseModel tempModel =
                ExpanseModel.fromJson(element.value as Map<String, dynamic>);
            double tempAmount = tempModel.amount;
            tempModel.amount += amount;
            await old.child(tempModel.id).set(tempModel.toJson());
            tempModel.amount -= tempAmount;
            await addStatistic(tempModel);
            notifyListeners();
            return true;
          }
        }
      }
      log("1");
      DatabaseReference ref = realtime.ref("expanses/$year/$month/$day").push();
      log("2");
      String id = ref.key!;
      log("İd: $id");
      ExpanseModel model = ExpanseModel(
          addedBy: AuthService.instance.currentUser.id,
          id: id,
          amount: amount,
          categoryId: categoryId,
          date: date);
      log("Model: ${model.toJson()}");
      await ref.set(model.toJson());
      await addStatistic(model);
      notifyListeners();
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<String?> addCategory(String name) async {
    // realtime done
    if (name.isEmpty) return null;
    if (categories.any((e) => e.name == name)) return null;
    try {
      DatabaseReference ref = realtime.ref("expanse_categories").push();
      String id = ref.key!;
      CategoryModel category = CategoryModel(id: id, name: name);
      await ref.set(category.toJson());
      await fillCategories();
      return id;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCategoryId(String name) async {
    // realtime done
    for (var element in categories) {
      if (element.name == name) return element.id;
    }
    return null;
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
    // realtime done
    try {
      String day = model.date.split("/")[0];
      String month = model.date.split("/")[1];
      String year = model.date.split("/")[2];
      await realtime.ref("expanses/$year/$month/$day/${model.id}").remove();
      await deleteStatistic(model);
      expanses.remove(model);
      PopupHelper.showSimpleSnackbar("Gider silindi");
      await fillExpanses();
    } catch (e) {
      PopupHelper.showSimpleSnackbar("Gider silinemedi", error: true);
    }
  }

  Future addStatistic(ExpanseModel model) async {
    String day = model.day;
    String month = model.month;
    String year = model.year;
    DatabaseReference ref = realtime.ref("expanses/$year/$month/$day");
    final dataDay = await ref.get();
    int totalDay = (dataDay.value! as Map)["total"] ?? 0;
    await ref.update({"total": totalDay + model.amount});
    final dataMonth = await realtime.ref("expanses/$year/$month").get();
    int totalMonth = (dataMonth.value! as Map)["total"] ?? 0;
    await realtime
        .ref("expanses/$year/$month")
        .update({"total": totalMonth + model.amount});
    final dataYear = await realtime.ref("expanses/$year").get();
    int totalYear = (dataYear.value! as Map)["total"] ?? 0;
    await realtime
        .ref("expanses/$year")
        .update({"total": totalYear + model.amount});
  }

  Future deneme() async {
    DatabaseReference ref = realtime.ref("expanses/2022/7/31");
    ref.update({"total": FieldValue.increment(100)});
    final data = await ref.get();
  }

  Future deleteStatistic(ExpanseModel model) async {
    String day = model.day;
    String month = model.month;
    String year = model.year;
    DatabaseReference ref = realtime.ref("expanses/$year/$month/$day");
    final dataDay = await ref.get();
    int totalDay = (dataDay.value! as Map)["total"];
    await ref.update({"total": totalDay - model.amount});
    final dataMonth = await realtime.ref("expanses/$year/$month").get();
    int totalMonth = (dataMonth.value! as Map)["total"];
    await realtime
        .ref("expanses/$year/$month")
        .update({"total": totalMonth - model.amount});
    final dataYear = await realtime.ref("expanses/$year").get();
    int totalYear = (dataYear.value! as Map)["total"];
    await realtime
        .ref("expanses/$year")
        .update({"total": totalYear - model.amount});
  }
}
