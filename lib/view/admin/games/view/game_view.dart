import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seanskayit/core/utils/ui/popup.dart';
import 'package:seanskayit/product/models/game_model.dart';
import 'package:seanskayit/view/admin/games/viewmodel/games_viewmodel.dart';

class GameView extends ConsumerStatefulWidget {
  GameModel? gameModel;
  ChangeNotifierProvider<GamesViewModel> provider;
  GameView({Key? key, this.gameModel, required this.provider})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddGameViewState();
}

class _AddGameViewState extends ConsumerState<GameView> {
  GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();

  Map<String, dynamic> data = {
    "name": "",
    "personFee": "",
    "personFeeDouble": "",
    "videoFee": "",
    "hours": [],
  };

  @override
  void initState() {
    if (widget.gameModel != null) {
      data = widget.gameModel!.toJson();
    }
    log(widget.gameModel.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data["name"].isEmpty ? "Oyun ekle" : data["name"]),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: widget.gameModel != null
            ? const Icon(Icons.check)
            : const Icon(Icons.add),
        onPressed: () async {
          if (widget.gameModel != null) {
            if (await ref.read(widget.provider).editGame(data)) {
              PopupHelper.showSimpleSnackbar("Oyun düzenlendi");
              Navigator.pop(context);
            } else {
              PopupHelper.showSimpleSnackbar("Oyun düzenlenemedi");
              formKey.currentState!.reset();
            }
          } else {
            if (await ref.read(widget.provider).addGame(data)) {
              PopupHelper.showSimpleSnackbar("Oyun eklendi");
              Navigator.pop(context);
            } else {
              PopupHelper.showSimpleSnackbar("Oyun eklenemedi");
              formKey.currentState!.reset();
            }
          }
        },
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 0.1.sh, horizontal: 0.1.sw),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  initialValue: widget.gameModel?.name,
                  onChanged: (value) {
                    data["name"] = value;
                  },
                  decoration: const InputDecoration(labelText: "Oyun adı"),
                ),
                TextFormField(
                  initialValue: widget.gameModel?.personFee.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    data["personFee"] = int.tryParse(value) ?? 0;
                  },
                  decoration: const InputDecoration(labelText: "Kişi ücreti"),
                ),
                TextFormField(
                  initialValue: widget.gameModel?.personFeeDouble.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    data["personFeeDouble"] = int.tryParse(value) ?? 0;
                  },
                  decoration: const InputDecoration(labelText: "2 kişi ücreti"),
                ),
                TextFormField(
                  initialValue: widget.gameModel?.videoFee.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    data["videoFee"] = int.tryParse(value) ?? 0;
                  },
                  decoration: const InputDecoration(labelText: "Video ücreti"),
                ),
                TextFormField(
                  initialValue: widget.gameModel?.hours.join(","),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    data["hours"] = value.split(",");
                  },
                  decoration: const InputDecoration(
                      labelText: "Saatler",
                      hintText: "Saatleri , ile ayır (11:30,12:30,13:30...)"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
