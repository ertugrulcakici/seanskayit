class SessionModel {
  String? id;
  String? name;
  late String addedBy;
  late int count;
  late String date;
  late String gameId;
  late num income;
  late bool video;
  late String hour;

  String get day => date.split('/')[0];
  String get month => date.split('/')[1];
  String get year => date.split('/')[2];

  String? phone;
  String? note;
  num? extra;
  num? discount;

  SessionModel.fromJson(Map<String, dynamic> json) {
    id = json.containsKey("id") ? json['id'] : null;
    name = json['name'];
    addedBy = json['addedBy'];
    count = json['count'];
    date = json['date'];
    gameId = json['gameId'];
    income = json['income'];
    video = json['video'];
    hour = json['hour'];

    phone = json['phone'];
    note = json['note'];
    extra = json['extra'];
    discount = json['discount'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'addedBy': addedBy,
      'count': count,
      'date': date,
      'gameId': gameId,
      'income': income,
      'video': video,
      'hour': hour,
    };

    if (id != null) data['id'] = id;
    if (phone != null) data['phone'] = phone;
    if (note != null) data['note'] = note;
    if (extra != null) data['extra'] = extra;
    if (discount != null) data['discount'] = discount;
    if (name != null) data['name'] = name;

    return data;
  }

  SessionModel copy() => SessionModel.fromJson(toJson());

  isEqualValues(SessionModel other) {
    return name == other.name &&
        addedBy == other.addedBy &&
        count == other.count &&
        date == other.date &&
        gameId == other.gameId &&
        income == other.income &&
        video == other.video &&
        hour == other.hour &&
        phone == other.phone &&
        note == other.note &&
        extra == other.extra &&
        discount == other.discount;
  }

  isNotEqualValues(SessionModel other) {
    return !isEqualValues(other);
  }

  @override
  String toString() => toJson().toString();
}
