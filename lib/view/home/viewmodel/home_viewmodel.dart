import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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

  num get totalIncome => sessions.fold(
      0, (sum, session) => session != null ? sum + session.income : 0);

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

    log("fill games listen");
    realtime.ref("games").onValue.listen((event) {
      fillGames();
    });
    log("fill sessions listen");
    realtime.ref("sessions").onValue.listen((event) {
      fillSessions();
    });
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
    // done
    try {
      EasyLoading.show(status: "Ekleniyor...");
      final DatabaseReference sessionRef = realtime
          .ref(
              "sessions/${sessionModel.gameId}/${sessionModel.year}/${sessionModel.month}/${sessionModel.day}")
          .push();
      sessionModel.id = sessionRef.key!;

      await _addStatistic(sessionModel);
      sessionRef.set(sessionModel.toJson());
      PopupHelper.showSimpleSnackbar("Seans eklendi");
      return true;
    } catch (e) {
      PopupHelper.showSimpleSnackbar("Seans eklenirken bir hata oluştu: $e");
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> deleteSession(SessionModel session) async {
    //  done
    try {
      EasyLoading.show(status: "Siliniyor...");
      await _deleteStatistic(session);
      DateTime now = DateTime.now();
      SessionLog sessionLog = SessionLog(
          date: now.D,
          hour: now.H,
          addedBy: AuthService.instance.currentUser.id,
          oldSession: session);
      final DatabaseReference sessionLogRef = realtime
          .ref(
              "session_logs/${sessionLog.year}/${sessionLog.month}/${sessionLog.day}")
          .push();
      sessionLog.id = sessionLogRef.key!;
      sessionLogRef.set(sessionLog.toJson());
      await realtime
          .ref(
              "sessions/${session.gameId}/${session.year}/${session.month}/${session.day}/${session.id}")
          .set(null);
      await _deleteStatistic(session);
      PopupHelper.showSimpleSnackbar("Seans silindi");
      return true;
    } catch (e) {
      return false;
    } finally {
      EasyLoading.dismiss();
    }
    // try {
    //   await firestore.runTransaction((transaction) async {
    //     transaction.delete(firestore.collection("sessions").doc(session.id));
    //     String id = firestore.collection("session_logs").doc().id;
    //     transaction.set(
    //         firestore.collection("session_logs").doc(id),
    //         SessionLog(
    //           id: id,
    //           oldSession: session,
    //           date: DateTime.now().D,
    //           hour: DateTime.now().H,
    //           addedBy: AuthService.instance.currentUser.id,
    //         ).toJson());
    //     await _deleteStatistic(session);
    //   });

    //   PopupHelper.showSimpleSnackbar("Seans silindi");
    //   return true;
    // } catch (e) {
    //   PopupHelper.showSimpleSnackbar("Seans silinirken bir hata oluştu: $e");
    //   return false;
    // }
  }

  Future updateSession(Map<String, dynamic> data, SessionModel copy) async {
    try {
      EasyLoading.show(status: "Güncelleniyor...");
      // data["note"] = data["note"] ?? FieldValue.delete();
      // data["discount"] = data["discount"] ?? FieldValue.delete();
      // data["extra"] = data["extra"] ?? FieldValue.delete();
      // data["phone"] = data["phone"] ?? FieldValue.delete();
      // data["name"] = data["name"] ?? FieldValue.delete();
      data.forEach((key, value) {
        log("$key: $value");
      });
      String day = data["date"].split("/")[0];
      String month = data["date"].split("/")[1];
      String year = data["date"].split("/")[2];
      String gameId = data["gameId"];
      await realtime
          .ref(
              "sessions/${copy.gameId}/${copy.year}/${copy.month}/${copy.day}/${copy.id}")
          .set(null);
      await realtime
          .ref("sessions/$gameId/$year/$month/$day/${copy.id}")
          .set(data);
      final addedSession = SessionModel.fromJson(data);
      if (copy.isNotEqualValues(addedSession)) {
        DateTime now = DateTime.now();
        final DatabaseReference sessionLogRef =
            realtime.ref("session_logs/$year/$month/$day").push();
        final sessionLogModel = SessionLog(
            id: sessionLogRef.key!,
            date: now.D,
            hour: now.H,
            addedBy: AuthService.instance.currentUser.id,
            oldSession: copy,
            newSession: addedSession);
        sessionLogRef.set(sessionLogModel.toJson());

        await _updateStatistic(copy, addedSession);
      }

      PopupHelper.showSimpleSnackbar("Seans güncellendi");
      return true;
    } catch (e) {
      PopupHelper.showSimpleSnackbar(
          "Seans güncellenirken bir hata oluştu: $e");
      return false;
    } finally {
      EasyLoading.dismiss();
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
    log("year: $year, month: $month, day: $day");

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
    if (sessionModel.video) {
      final videoRef = gameRef.child("video/$dateString");
      final videoData = await videoRef.get();
      if (videoData.exists) {
        log("update video");
        num newValue = (videoData.value as num) + 1;
        await videoRef.set(newValue);
        await videoRef.parent!.update({"total": newValue});
        await videoRef.parent!.parent!.update({"total": newValue});
        await videoRef.parent!.parent!.parent!.update({"total": newValue});
      } else {
        log("set video");
        await videoRef.set(1);
        await videoRef.parent!.update({"total": 1});
        await videoRef.parent!.parent!.update({"total": 1});
        await videoRef.parent!.parent!.parent!.update({"total": 1});
      }
    }

    if (sessionModel.extra != null) {
      final extraRef = gameRef.child("extra/$dateString");
      final extraData = await extraRef.get();
      if (extraData.exists) {
        log("update extra");
        num newValue = (extraData.value as num) + sessionModel.extra!;
        await extraRef.set(newValue);
        await extraRef.parent!.update({"total": newValue});
        await extraRef.parent!.parent!.update({"total": newValue});
        await extraRef.parent!.parent!.parent!.update({"total": newValue});
      } else {
        log("set extra");
        await extraRef.set(sessionModel.extra!);
        await extraRef.parent!.update({"total": sessionModel.extra!});
        await extraRef.parent!.parent!.update({"total": sessionModel.extra!});
        await extraRef.parent!.parent!.parent!
            .update({"total": sessionModel.extra!});
      }
    }

    //discount
    if (sessionModel.discount != null) {
      final discountRef = gameRef.child("discount/$dateString");
      final discountData = await discountRef.get();
      if (discountData.exists) {
        log("update discount");
        num newValue = (discountData.value as num) + sessionModel.discount!;
        await discountRef.set(newValue);
        await discountRef.parent!.update({"total": newValue});
        await discountRef.parent!.parent!.update({"total": newValue});
        await discountRef.parent!.parent!.parent!.update({"total": newValue});
      } else {
        log("set discount");
        await discountRef.set(sessionModel.discount!);
        await discountRef.parent!.update({"total": sessionModel.discount!});
        await discountRef.parent!.parent!
            .update({"total": sessionModel.discount!});
        await discountRef.parent!.parent!.parent!
            .update({"total": sessionModel.discount!});
      }
    }

    //count
    final countRef = gameRef.child("count/$dateString");
    final countData = await countRef.get();
    if (countData.exists) {
      log("update count");
      num newValue = (countData.value as num) + sessionModel.count;
      await countRef.set(newValue);
      await countRef.parent!.update({"total": newValue});
      await countRef.parent!.parent!.update({"total": newValue});
      await countRef.parent!.parent!.parent!.update({"total": newValue});
    } else {
      log("set count");
      await countRef.set(sessionModel.count);
      await countRef.parent!.update({"total": sessionModel.count});
      await countRef.parent!.parent!.update({"total": sessionModel.count});
      await countRef.parent!.parent!.parent!
          .update({"total": sessionModel.count});
    }
  }

  Future _deleteStatistic(SessionModel sessionModel) async {
    String dateString =
        "${sessionModel.date.split("/")[2]}/${sessionModel.date.split("/")[1]}/${sessionModel.date.split("/")[0]}";
    final gameRef = realtime.ref("statistic/${sessionModel.gameId}/");
    final incomeRef = gameRef.child("income/$dateString");
    final incomeData = await incomeRef.get();
    await incomeRef.set((incomeData.value as num) - sessionModel.income);
    await incomeRef.parent!
        .update({"total": (incomeData.value as num) - sessionModel.income});
    await incomeRef.parent!.parent!
        .update({"total": (incomeData.value as num) - sessionModel.income});
    await incomeRef.parent!.parent!.parent!
        .update({"total": (incomeData.value as num) - sessionModel.income});

    if (sessionModel.video) {
      final videoRef = gameRef.child("video/$dateString");
      final videoData = await videoRef.get();
      await videoRef.set((videoData.value as num) - 1);
      await videoRef.parent!.update({"total": (videoData.value as num) - 1});
      await videoRef.parent!.parent!
          .update({"total": (videoData.value as num) - 1});
    }

    if (sessionModel.extra != null) {
      final extraRef = gameRef.child("extra/$dateString");
      final extraData = await extraRef.get();

      await extraRef.set((extraData.value as num) - (sessionModel.extra ?? 0));
      await extraRef.parent!.update(
          {"total": (extraData.value as num) - (sessionModel.extra ?? 0)});
      await extraRef.parent!.parent!.update(
          {"total": (extraData.value as num) - (sessionModel.extra ?? 0)});
      await extraRef.parent!.parent!.parent!.update(
          {"total": (extraData.value as num) - (sessionModel.extra ?? 0)});
    }

    if (sessionModel.discount != null) {
      final discountRef = gameRef.child("discount/$dateString");
      final discountData = await discountRef.get();
      await discountRef
          .set((discountData.value as num) - (sessionModel.discount ?? 0));
      await discountRef.parent!.update({
        "total": (discountData.value as num) - (sessionModel.discount ?? 0)
      });
      await discountRef.parent!.parent!.update({
        "total": (discountData.value as num) - (sessionModel.discount ?? 0)
      });
      await discountRef.parent!.parent!.parent!.update({
        "total": (discountData.value as num) - (sessionModel.discount ?? 0)
      });
    }

    final countRef = gameRef.child("count/$dateString");
    final countData = await countRef.get();
    await countRef.set((countData.value as num) - sessionModel.count);
    await countRef.parent!
        .update({"total": (countData.value as num) - sessionModel.count});
    await countRef.parent!.parent!
        .update({"total": (countData.value as num) - sessionModel.count});
    await countRef.parent!.parent!.parent!
        .update({"total": (countData.value as num) - sessionModel.count});
  }

  Future _updateStatistic(SessionModel oldModel, SessionModel newModel) async {
    await _deleteStatistic(oldModel);
    await _addStatistic(newModel);
  }
}
