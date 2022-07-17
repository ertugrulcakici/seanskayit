import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:seanskayit/core/services/firebase/firebase_service.dart';
import 'package:seanskayit/core/utils/datetime_extentions.dart';
import 'package:seanskayit/product/models/game_model.dart';
import 'package:seanskayit/product/models/session_log_model.dart';
import 'package:seanskayit/product/models/user_model.dart';

class SessionHistoryViewModel extends ChangeNotifier with FirebaseService {
  String _date = "";
  String get date => _date;
  set date(String value) {
    _date = value;
    fillLogs();
  }

  List<UserModel> users = [];
  List<GameModel> games = [];
  Future<Map<String, dynamic>> getIdToStrings(
      {required String gameId,
      required String firstAddedUserId,
      required String addedUserId,
      String? newGameId}) async {
    Map<String, dynamic> data = {
      "gameName": "",
      "addedName": "",
      "firstAddedName": ""
    };
    if (!users.any((element) => element.id == firstAddedUserId)) {
      await addUser(firstAddedUserId);
    }
    if (!users.any((element) => element.id == addedUserId)) {
      await addUser(addedUserId);
    }
    if (!games.any((element) => element.id == gameId)) {
      await addGame(gameId);
    }
    if (newGameId != null && !games.any((element) => element.id == newGameId)) {
      await addGame(newGameId);
    }

    data["firstAddedName"] =
        users.firstWhere((element) => element.id == firstAddedUserId).name;

    data["addedName"] =
        users.firstWhere((element) => element.id == addedUserId).name;

    data["gameName"] = games.firstWhere((element) => element.id == gameId).name;

    if (newGameId != null) {
      data["newGameName"] =
          games.firstWhere((element) => element.id == newGameId).name;
    }

    return data;
  }

  Future addGame(String gameId) async {
    DocumentSnapshot doc =
        await firestore.collection("games").doc(gameId).get();
    GameModel game = GameModel.fromJson(doc.data() as Map<String, dynamic>);
    games.add(game);
    notifyListeners();
  }

  Future addUser(String userId) async {
    DocumentSnapshot doc =
        await firestore.collection("users").doc(userId).get();
    UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    users.add(user);
    notifyListeners();
  }

  List<SessionLog> sessionLogs = [];

  Future init() async {
    _date = DateTime.now().D;
    await fillLogs();
  }

  Future fillLogs() async {
    QuerySnapshot result = await firestore
        .collection("session_logs")
        .where("date", isEqualTo: _date)
        .get();
    sessionLogs = result.docs
        .map((doc) => SessionLog.fromJson(doc.data() as Map<String, dynamic>))
        .toList();

    notifyListeners();
  }

  deleteSessionLog(SessionLog sessionLog) async {
    await firestore.collection("session_logs").doc(sessionLog.id).delete();
    fillLogs();
  }
}
