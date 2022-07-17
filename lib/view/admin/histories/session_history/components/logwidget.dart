import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seanskayit/product/models/session_log_model.dart';

class LogWidget extends StatelessWidget {
  final SessionLog log;
  String gameName;
  String addedName;
  String firstAddedName;
  String? newGameName;
  LogWidget(
      {Key? key,
      required this.log,
      required this.gameName,
      required this.addedName,
      required this.firstAddedName,
      this.newGameName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: log.newSession == null ? _onlyOld() : _both(),
    );
  }

  Widget _onlyOld() {
    List<String> sessionInfo = [];

    sessionInfo.add("Oyun: $gameName");
    sessionInfo.add("Tarih: ${log.oldSession.date}");
    sessionInfo.add("Saat: ${log.oldSession.hour}");
    if (log.oldSession.name != null) {
      sessionInfo.add("İsim: ${log.oldSession.name}");
    }
    sessionInfo.add("Sayı: ${log.oldSession.count}");
    if (log.oldSession.phone != null) {
      sessionInfo.add("Numara: ${log.oldSession.phone}");
    }
    if (log.oldSession.extra != null) {
      sessionInfo.add("Ekstra: ${log.oldSession.extra}");
    }
    if (log.oldSession.discount != null) {
      sessionInfo.add("İndirim: ${log.oldSession.discount}");
    }
    if (log.oldSession.note != null) {
      sessionInfo.add("Not: ${log.oldSession.note}");
    }
    sessionInfo.add("Video: ${log.oldSession.video ? "Var" : "Yok"}");
    return Column(
      children: [
        Text("Seans bilgileri",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ...sessionInfo.map((e) => Text(e)).toList(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Silen kişi: $addedName",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Silinme saati: ${log.hour}",
                style: const TextStyle(fontWeight: FontWeight.bold))
          ],
        )
      ],
    );
  }

  Widget _both() {
    List<String> oldSessionInfo = [];
    List<String> newSessionInfo = [];

    oldSessionInfo.add("Oyun: $gameName");
    newSessionInfo.add("Oyun: $newGameName");
    oldSessionInfo.add("Tarih: ${log.oldSession.date}");
    newSessionInfo.add("Tarih: ${log.newSession!.date}");
    oldSessionInfo.add("Saat: ${log.oldSession.hour}");
    newSessionInfo.add("Saat: ${log.newSession!.hour}");
    if (log.oldSession.name != null) {
      oldSessionInfo.add("İsim: ${log.oldSession.name}");
      newSessionInfo.add("İsim: ${log.newSession!.name}");
    }
    oldSessionInfo.add("Sayı: ${log.oldSession.count}");
    newSessionInfo.add("Sayı: ${log.newSession!.count}");
    if (log.oldSession.phone != null) {
      oldSessionInfo.add("Numara: ${log.oldSession.phone}");
      newSessionInfo.add("Numara: ${log.newSession!.phone}");
    }
    if (log.oldSession.extra != null) {
      oldSessionInfo.add("Ekstra: ${log.oldSession.extra}");
      newSessionInfo.add("Ekstra: ${log.newSession!.extra}");
    }
    if (log.oldSession.discount != null) {
      oldSessionInfo.add("İndirim: ${log.oldSession.discount}");
      newSessionInfo.add("İndirim: ${log.newSession!.discount}");
    }
    if (log.oldSession.note != null) {
      oldSessionInfo.add("Not: ${log.oldSession.note}");
      newSessionInfo.add("Not: ${log.newSession!.note}");
    }
    oldSessionInfo.add("Video: ${log.oldSession.video ? "Var" : "Yok"}");
    newSessionInfo.add("Video: ${log.newSession!.video ? "Var" : "Yok"}");
    return Column(
      children: [
        Text("Seans bilgileri",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: oldSessionInfo.map((e) => Text(e)).toList()),
            Column(
              children: newSessionInfo.map((e) => Text(e)).toList(),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Güncelleyen kişi: $addedName",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Güncellenme saati: ${log.hour}",
                style: const TextStyle(fontWeight: FontWeight.bold))
          ],
        )
      ],
    );
  }
}
