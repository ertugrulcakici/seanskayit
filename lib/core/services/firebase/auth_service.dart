import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seanskayit/core/services/cache/locale_manager.dart';
import 'package:seanskayit/core/services/firebase/firebase_service.dart';
import 'package:seanskayit/product/enums/locale_enums.dart';
import 'package:seanskayit/product/models/user_model.dart';

class AuthService extends FirebaseService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  AuthService._internal();

  static late UserModel _currentUser;
  UserModel get currentUser => _currentUser;

  Future<bool> login(String password) async {
    QuerySnapshot<Map<String, dynamic>> query = await firestore
        .collection("users")
        .where("password", isEqualTo: password)
        .where("active", isEqualTo: true)
        .get();
    if (query.docs.isNotEmpty) {
      QueryDocumentSnapshot snapshot = query.docs.first;
      String lastLogin = DateTime.now().toString();
      firestore.collection("users").doc(snapshot.id).update({
        "lastLogin": lastLogin,
      });
      _currentUser =
          UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      LocaleManager.instance
          .setString(LocaleEnum.currentUserId, _currentUser.id);
      LocaleManager.instance.setString(LocaleEnum.lastLogin, lastLogin);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    String? id = LocaleManager.instance.getString(LocaleEnum.currentUserId);
    if (id == null) {
      return false;
    }
    DocumentSnapshot documentSnapshot =
        await firestore.collection("users").doc(id).get();
    final user =
        UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
    if (user.active &&
        user.lastLogin ==
            LocaleManager.instance.getString(LocaleEnum.lastLogin)) {
      _currentUser = user;
      return true;
    } else {
      return false;
    }
  }

  Future<int> getProgramVersion() async {
    final snapshot =
        await firestore.collection("settings").doc("app_settings").get();
    int version = (snapshot.data() as Map)["version"] as int;
    return version;
  }
}
