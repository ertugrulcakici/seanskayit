import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seanskayit/core/utils/datetime_extentions.dart';
import 'package:seanskayit/view/admin/histories/session_history/components/logwidget.dart';
import 'package:seanskayit/view/admin/histories/session_history/viewmodel/session_history_viewmodel.dart';

class SessionHistoryView extends ConsumerStatefulWidget {
  const SessionHistoryView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SessionHistoryViewState();
}

class _SessionHistoryViewState extends ConsumerState<SessionHistoryView> {
  ChangeNotifierProvider<SessionHistoryViewModel> provider =
      ChangeNotifierProvider((_) => SessionHistoryViewModel());

  @override
  void initState() {
    ref.read(provider).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("Seans geçmişi"),
            SizedBox(width: 0.01.sw),
            TextButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(ref.watch(provider).date))
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: ref.watch(provider).sessionLogs.length,
        itemBuilder: (context, index) {
          return FutureBuilder<Map<String, dynamic>>(
            future: ref.watch(provider).getIdToStrings(
                newGameId:
                    ref.watch(provider).sessionLogs[index].newSession?.gameId,
                gameId:
                    ref.watch(provider).sessionLogs[index].oldSession.gameId,
                firstAddedUserId:
                    ref.watch(provider).sessionLogs[index].oldSession.addedBy,
                addedUserId: ref.watch(provider).sessionLogs[index].addedBy),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return InkWell(
                  onLongPress: () => _delete(index),
                  child: LogWidget(
                      log: ref.watch(provider).sessionLogs[index],
                      gameName: snapshot.data!["gameName"],
                      addedName: snapshot.data!["addedName"],
                      firstAddedName: snapshot.data!["firstAddedName"],
                      newGameName: snapshot.data!["newGameName"]),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          );
        },
      ),
    );
  }

  void _selectDate() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2010),
            lastDate: DateTime(2030))
        .then((value) {
      if (value != null) {
        ref.read(provider).date = value.D;
      }
    });
  }

  Future _delete(int index) async {
    AwesomeDialog(
      context: context,
      btnOkText: "Kaydı silmek istediğine emin misin?",
      btnOkColor: Colors.red,
      btnOkIcon: Icons.delete,
      btnOkOnPress: () {
        ref
            .read(provider)
            .deleteSessionLog(ref.watch(provider).sessionLogs[index]);
      },
      btnCancelText: "İptal",
      btnCancelColor: Colors.black,
      btnCancelIcon: Icons.cancel,
      btnCancelOnPress: () {},
    ).show();
  }
}
