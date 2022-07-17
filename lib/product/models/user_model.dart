class UserModel {
  late String name;
  late String id;
  late bool isAdmin;
  bool active;
  String? password;
  String? lastLogin;

  UserModel(
      {required this.name,
      required this.id,
      required this.isAdmin,
      required this.active,
      this.password,
      this.lastLogin});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        name: json["name"],
        id: json["id"],
        isAdmin: json["isAdmin"],
        active: json["active"],
        password: json.containsKey("password") ? json["password"] : null,
        lastLogin: json.containsKey("lastLogin") ? json["lastLogin"] : null,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "name": name,
      "id": id,
      "isAdmin": isAdmin,
      "active": active,
    };
    if (password != null) data["password"] = password;
    if (lastLogin != null) data["lastLogin"] = lastLogin;
    return data;
  }
}
