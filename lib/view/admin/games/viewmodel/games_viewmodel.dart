import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:seanskayit/core/services/firebase/firebase_service.dart';
import 'package:seanskayit/product/models/game_model.dart';

class GamesViewModel extends ChangeNotifier with FirebaseService {
  GamesViewModel();
  List<GameModel> games = [];
  final Duration _duration = const Duration(milliseconds: 500);

  Future<void> fillGames() async {
    QuerySnapshot games = await firestore.collection("games").get();
    for (var element in games.docs) {
      this
          .games
          .add(GameModel.fromJson(element.data() as Map<String, dynamic>));
    }
    Future.delayed(_duration, () {
      notifyListeners();
    });
  }

  Future<bool> deleteGame(String id) async {
    try {
      await firestore.collection("games").doc(id).delete();
      games.removeWhere((element) => element.id == id);
      Future.delayed(_duration, () {
        notifyListeners();
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addGame(Map<String, dynamic> data) async {
    try {
      String id = firestore.collection("games").doc().id;
      data["id"] = id;
      GameModel game = GameModel.fromJson(data);
      games.add(game);
      await firestore.collection("games").doc(id).set(game.toJson());
      Future.delayed(_duration, () {
        notifyListeners();
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editGame(Map<String, dynamic> data) async {
    GameModel model = GameModel.fromJson(data);
    try {
      await firestore.collection("games").doc(model.id).set(model.toJson());
      games = games.map((e) {
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
