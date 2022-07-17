import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:seanskayit/core/services/firebase/auth_service.dart';
import 'package:seanskayit/core/services/firebase/firebase_service.dart';
import 'package:seanskayit/core/utils/datetime_extentions.dart';
import 'package:seanskayit/core/utils/ui/popup.dart';
import 'package:seanskayit/product/models/game_model.dart';
import 'package:seanskayit/product/models/session_log_model.dart';
import 'package:seanskayit/product/models/session_model.dart';
import 'package:seanskayit/product/models/user_model.dart';

class HomeViewModel extends ChangeNotifier with FirebaseService {
  List<GameModel> games = [];
  List<SessionModel?> sessions = [];
  List<UserModel> users = [];

  GameModel? _selectedGame;
  GameModel? get selectedGame => _selectedGame;
  set selectedGame(GameModel? value) {
    _selectedGame = value;
    fillSessions();
  }

  num get totalCount => sessions.fold(
      0, (sum, session) => sum + (session != null ? session.count : 0));

  num get totalExtraCount => sessions.fold(
      0, (sum, session) => sum + (session != null ? session.extra ?? 0 : 0));

  num get totalDiscountCount => sessions.fold(
      0, (sum, session) => sum + (session != null ? session.discount ?? 0 : 0));

  num get totalVideoCount => sessions.fold(
      0,
      (sum, session) =>
          sum +
          (session != null
              ? session.video
                  ? 1
                  : 0
              : 0));

  String _date = "";
  String get date => _date;
  set date(String value) {
    _date = value;
    fillSessions();
  }

  HomeViewModel();

  Future init() async {
    _date = DateTime.now().D;
    log("init çağırma");
    await fillUsers();
    await fillGames();
    await fillSessions();

    realtime.ref("games").onChildChanged.listen((event) {
      fillGames();
    });
    realtime.ref("sessions").onChildChanged.listen((event) {
      fillSessions();
    });

    // firestore.collection("games").snapshots().listen((event) {}).onData((data) {
    //   fillGames();
    // });

    // firestore
    //     .collection("sessions")
    //     .snapshots()
    //     .listen((event) {})
    //     .onData((data) {
    //   fillSessions();
    // });
  }

  Future fillGames() async {
    games.clear();
    log("fill games");
    final docSnaphsot =
        await firestore.collection("games").orderBy("name").get();
    for (var element in docSnaphsot.docs) {
      try {
        final game = GameModel.fromJson(element.data());
        games.add(game);
      } catch (e) {
        PopupHelper.showSimpleSnackbar("Oyun getirilirken hata oluştu");
      }
    }
    if (games.isNotEmpty) {
      _selectedGame = games.first;
      sessions
          .addAll(List.generate(selectedGame!.hours.length, (index) => null));
    }
    notifyListeners();
  }

  Future fillSessions() async {
    if (selectedGame != null) {
      log("fill sessions");
      sessions.clear();
      String day = _date.split("/")[0];
      String month = _date.split("/")[1];
      String year = _date.split("/")[2];
      final result = await realtime
          .ref("sessions/${selectedGame!.id}/$year/$month/$day")
          .get();

      // final result = await firestore
      //     .collection("sessions")
      //     .where("gameId", isEqualTo: selectedGame!.id)
      //     .where("date", isEqualTo: date)
      //     .get();

      sessions
          .addAll(List.generate(selectedGame!.hours.length, (index) => null));

      // ignore: avoid_function_literals_in_foreach_calls
      result.children.forEach((element) {
        final session =
            SessionModel.fromJson(element.value! as Map<String, dynamic>);
        int index = selectedGame!.hours.indexWhere((hour) {
          if (hour == session.hour) {
            return true;
          }
          return false;
        });
        if (index != -1) {
          sessions[index] = session;
        } else {
          log("index -1 geldi");
        }
      });
      notifyListeners();
    }
  }

  Future<bool> addSession(SessionModel sessionModel) async {
    try {
      var sessionRef = realtime
          .ref(
              "sessions/${sessionModel.gameId}/${sessionModel.year}/${sessionModel.month}/${sessionModel.day}")
          .push();
      String id = sessionRef.key!;
      sessionModel.id = id;
      sessionRef.set(sessionModel.toJson());
      // String id = firestore.collection("sessions").doc().id;
      // sessionModel.id = id;
      // await firestore
      //     .collection("sessions")
      //     .doc(id)
      //     .set(sessionModel.toJson(), SetOptions(merge: true));
      // await _addStatistic(sessionModel);
      // PopupHelper.showSimpleSnackbar("Seans eklendi");
      return true;
    } catch (e) {
      PopupHelper.showSimpleSnackbar("Seans eklenirken bir hata oluştu: $e");
      return false;
    }
  }

  Future<bool> deleteSession(SessionModel session) async {
    try {
      await firestore.runTransaction((transaction) async {
        transaction.delete(firestore.collection("sessions").doc(session.id));
        String id = firestore.collection("session_logs").doc().id;
        transaction.set(
            firestore.collection("session_logs").doc(id),
            SessionLog(
              id: id,
              oldSession: session,
              date: DateTime.now().D,
              hour: DateTime.now().H,
              addedBy: AuthService.instance.currentUser.id,
            ).toJson());
        await _deleteStatistic(session);
      });

      PopupHelper.showSimpleSnackbar("Seans silindi");
      return true;
    } catch (e) {
      PopupHelper.showSimpleSnackbar("Seans silinirken bir hata oluştu: $e");
      return false;
    }
  }

  Future updateSession(Map<String, dynamic> data, SessionModel copy) async {
    try {
      data["note"] = data["note"] ?? FieldValue.delete();
      data["discount"] = data["discount"] ?? FieldValue.delete();
      data["extra"] = data["extra"] ?? FieldValue.delete();
      data["phone"] = data["phone"] ?? FieldValue.delete();
      data["name"] = data["name"] ?? FieldValue.delete();
      await firestore.collection("sessions").doc(data["id"]).update(data);
      DocumentSnapshot doc =
          await firestore.collection("sessions").doc(data["id"]).get();
      final addedSession =
          SessionModel.fromJson(doc.data() as Map<String, dynamic>);
      if (copy.isNotEqualValues(addedSession)) {
        String id = firestore.collection("session_logs").doc().id;
        await firestore.collection("session_logs").doc(id).set(SessionLog(
              id: id,
              oldSession: copy,
              newSession: addedSession,
              date: DateTime.now().D,
              hour: DateTime.now().H,
              addedBy: AuthService.instance.currentUser.id,
            ).toJson());
        await _updateStatistic(copy, addedSession);
      }

      PopupHelper.showSimpleSnackbar("Seans güncellendi");
      return true;
    } catch (e) {
      PopupHelper.showSimpleSnackbar(
          "Seans güncellenirken bir hata oluştu: $e");
      return false;
    }
  }

  Future fillUsers() async {
    users.clear();
    log("fill users");
    final docSnaphsot = await firestore.collection("users").get();
    for (var element in docSnaphsot.docs) {
      try {
        final user = UserModel.fromJson(element.data());
        users.add(user);
      } catch (e) {
        PopupHelper.showSimpleSnackbar("Kullanıcı getirilirken hata oluştu");
      }
    }
  }

  Future _addStatistic(SessionModel sessionModel) async {
    String dateString =
        "${sessionModel.date.split("/")[2]}/${sessionModel.date.split("/")[1]}/${sessionModel.date.split("/")[0]}";
    log(dateString);
    String year = dateString.split("/")[0];
    String month = dateString.split("/")[1];
    String day = dateString.split("/")[2];

    final gameRef = realtime.ref("statistic/${sessionModel.gameId}/");

    // income
    final incomeRef = gameRef.child("income/$dateString");
    final incomeData = await incomeRef.get();
    if (incomeData.exists) {
      log("update income");
      num newValue = (incomeData.value as num) + sessionModel.income;
      log("new value: $newValue");
      await incomeRef.set(newValue);
      await incomeRef.parent!.update({
        "total": ((await incomeRef.parent!.child("total").get()).value as num) +
            sessionModel.income
      });
      await incomeRef.parent!.parent!.update({
        "total": ((await incomeRef.parent!.parent!.child("total").get()).value
                as num) +
            sessionModel.income
      });
      await incomeRef.parent!.parent!.parent!.update({
        "total": ((await incomeRef.parent!.parent!.parent!.child("total").get())
                .value as num) +
            sessionModel.income
      });
    } else {
      log("set income");
      await incomeRef.set(sessionModel.income);
      await incomeRef.parent!.update({"total": sessionModel.income});
      await incomeRef.parent!.parent!.update({"total": sessionModel.income});
      await incomeRef.parent!.parent!.parent!
          .update({"total": sessionModel.income});
    }

    //video
    final videoRef = gameRef.child("video/$dateString");
    final videoData = await videoRef.get();
    if (videoData.exists) {
      log("update video");
      num newValue = (videoData.value as num) + (sessionModel.video ? 1 : 0);
      await videoRef.set(newValue);
      await videoRef.parent!
          .update({"total": FieldValue.increment(sessionModel.video ? 1 : 0)});
      await videoRef.parent!.parent!
          .update({"total": FieldValue.increment(sessionModel.video ? 1 : 0)});
      await videoRef.parent!.parent!.parent!
          .update({"total": FieldValue.increment(sessionModel.video ? 1 : 0)});
    } else {
      log("set video");
      await videoRef.set(sessionModel.video ? 1 : 0);
      await videoRef.parent!.update({"total": sessionModel.video ? 1 : 0});
      await videoRef.parent!.parent!
          .update({"total": sessionModel.video ? 1 : 0});
      await videoRef.parent!.parent!.parent!
          .update({"total": sessionModel.video ? 1 : 0});
    }

    // //extra
    // final extraRef = gameRef.child("extra/$dateString");
    // final extraData = await extraRef.get();
    // if (extraData.exists) {
    //   await extraRef.set((extraData.value as num) + (sessionModel.extra ?? 0));
    // } else {
    //   await extraRef.set(sessionModel.extra ?? 0);
    //   await gameRef.child("extra").update({"total": sessionModel.extra ?? 0});
    //   await gameRef
    //       .child("extra/$year")
    //       .update({"total": sessionModel.extra ?? 0});
    //   await gameRef
    //       .child("extra/$year/$month")
    //       .update({"total": sessionModel.extra ?? 0});
    // }
    // await gameRef
    //     .child("extra")
    //     .update({"total": FieldValue.increment(sessionModel.extra ?? 0)});
    // await gameRef
    //     .child("extra/$year")
    //     .update({"total": FieldValue.increment(sessionModel.extra ?? 0)});
    // await gameRef
    //     .child("extra/$year/$month")
    //     .update({"total": FieldValue.increment(sessionModel.extra ?? 0)});

    // //discount
    // final discountRef = gameRef.child("discount/$dateString");
    // final discountData = await discountRef.get();
    // if (discountData.exists) {
    //   await discountRef
    //       .set((discountData.value as num) + (sessionModel.discount ?? 0));
    // } else {
    //   await discountRef.set(sessionModel.discount ?? 0);
    //   await gameRef
    //       .child("discount")
    //       .update({"total": sessionModel.discount ?? 0});
    //   await gameRef
    //       .child("discount/$year")
    //       .update({"total": sessionModel.discount ?? 0});
    //   await gameRef
    //       .child("discount/$year/$month")
    //       .update({"total": sessionModel.discount ?? 0});
    // }
    // await gameRef
    //     .child("discount")
    //     .update({"total": FieldValue.increment(sessionModel.discount ?? 0)});
    // await gameRef
    //     .child("discount/$year")
    //     .update({"total": FieldValue.increment(sessionModel.discount ?? 0)});
    // await gameRef
    //     .child("discount/$year/$month")
    //     .update({"total": FieldValue.increment(sessionModel.discount ?? 0)});

    // //count
    // final countRef = gameRef.child("count/$dateString");
    // final countData = await countRef.get();
    // if (countData.exists) {
    //   await countRef.set((countData.value as num) + sessionModel.count);
    // } else {
    //   await countRef.set(sessionModel.count);
    //   await gameRef.child("count").update({"total": sessionModel.count});
    //   log("count total oluştu");
    //   await gameRef.child("count/$year").update({"total": sessionModel.count});
    //   log("count/$year total oluştu");
    //   await gameRef
    //       .child("count/$year/$month")
    //       .update({"total": sessionModel.count});
    //   log("count/$year/$month total oluştu");
    // }
    // await gameRef
    //     .child("count")
    //     .update({"total": FieldValue.increment(sessionModel.count)});
    // await gameRef
    //     .child("count/$year")
    //     .update({"total": FieldValue.increment(sessionModel.count)});
    // await gameRef
    //     .child("count/$year/$month")
    //     .update({"total": FieldValue.increment(sessionModel.count)});
  }

  Future _deleteStatistic(SessionModel sessionModel) async {
    String dateString =
        "${sessionModel.date.split("/")[2]}/${sessionModel.date.split("/")[1]}/${sessionModel.date.split("/")[0]}";
    final gameRef = realtime.ref("statistic/${sessionModel.gameId}/");
    final incomeRef = gameRef.child("income/$dateString");
    final incomeData = await incomeRef.get();
    if (incomeData.exists) {
      incomeRef.set((incomeData.value as num) - sessionModel.income);
    } else {
      incomeRef.set(sessionModel.income);
    }
    final videoRef = gameRef.child("video/$dateString");
    final videoData = await videoRef.get();
    if (videoData.exists) {
      videoRef.set((videoData.value as num) - (sessionModel.video ? 1 : 0));
    } else {
      videoRef.set(sessionModel.video ? 1 : 0);
    }
    final extraRef = gameRef.child("extra/$dateString");
    final extraData = await extraRef.get();
    if (extraData.exists) {
      extraRef.set((extraData.value as num) - (sessionModel.extra ?? 0));
    } else {
      extraRef.set(sessionModel.extra ?? 0);
    }
    final discountRef = gameRef.child("discount/$dateString");
    final discountData = await discountRef.get();
    if (discountData.exists) {
      discountRef
          .set((discountData.value as num) - (sessionModel.discount ?? 0));
    } else {
      discountRef.set(sessionModel.discount ?? 0);
    }
    final countRef = gameRef.child("count/$dateString");
    final countData = await countRef.get();
    if (countData.exists) {
      countRef.set((countData.value as num) - sessionModel.count);
    } else {
      countRef.set(sessionModel.count);
    }
  }

  Future _updateStatistic(SessionModel oldModel, SessionModel newModel) async {
    await _deleteStatistic(oldModel);
    await _addStatistic(newModel);
  }
}
