import 'package:seanskayit/product/models/session_model.dart';

class SessionLog {
  String? id;
  SessionModel? newSession;
  SessionModel oldSession;
  String date;
  String hour;
  String addedBy;

  SessionLogType get type =>
      newSession == null ? SessionLogType.delete : SessionLogType.update;

  SessionLog({
    this.id,
    this.newSession,
    required this.oldSession,
    required this.date,
    required this.hour,
    required this.addedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "newSession": newSession?.toJson(),
      "oldSession": oldSession.toJson(),
      "date": date,
      "hour": hour,
      "changedBy": addedBy,
    };
  }

  factory SessionLog.fromJson(Map<String, dynamic> json) {
    return SessionLog(
      addedBy: json["changedBy"],
      date: json["date"],
      hour: json["hour"],
      id: json["id"],
      newSession: json["newSession"] != null
          ? SessionModel.fromJson(json["newSession"] as Map<String, dynamic>)
          : null,
      oldSession:
          SessionModel.fromJson(json["oldSession"] as Map<String, dynamic>),
    );
  }

  @override
  String toString() => toJson().toString();
}

enum SessionLogType { delete, update }
