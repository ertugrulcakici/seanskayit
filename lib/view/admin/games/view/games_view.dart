import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seanskayit/core/services/navigation/navigation_service.dart';
import 'package:seanskayit/product/models/game_model.dart';
import 'package:seanskayit/view/admin/games/view/game_view.dart';
import 'package:seanskayit/view/admin/games/viewmodel/games_viewmodel.dart';

class GamesView extends ConsumerStatefulWidget {
  const GamesView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GamesViewState();
}

class _GamesViewState extends ConsumerState<GamesView> {
  final ChangeNotifierProvider<GamesViewModel> provider =
      ChangeNotifierProvider<GamesViewModel>(
    (ref) => GamesViewModel(),
  );

  @override
  void initState() {
    ref.read(provider).fillGames();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Oyunlar"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          NavigationService.navigateWithWidget(GameView(provider: provider));
        },
      ),
      body: Center(
          child: ListView.builder(
        shrinkWrap: true,
        itemCount: ref.watch(provider).games.length,
        itemBuilder: (context, index) {
          GameModel game = ref.watch(provider).games[index];
          return InkWell(
            onLongPress: () {
              AwesomeDialog(
                context: context,
                btnOkText: "Sil",
                btnOkColor: Colors.red,
                btnOkIcon: Icons.delete,
                btnOkOnPress: () {
                  AwesomeDialog(
                    context: context,
                    btnOkText: "Evet",
                    btnOkColor: Colors.red,
                    btnOkIcon: Icons.delete,
                    btnOkOnPress: () {
                      ref.read(provider).deleteGame(game.id);
                    },
                    btnCancelText: "Hayır",
                    btnCancelColor: Colors.blue,
                    btnCancelIcon: Icons.close,
                    btnCancelOnPress: () {},
                    headerAnimationLoop: false,
                    dialogType: DialogType.WARNING,
                    animType: AnimType.BOTTOMSLIDE,
                    title: "Son kararın mı ?",
                  ).show();
                },
                btnCancelText: "İptal",
                btnCancelOnPress: () {},
                headerAnimationLoop: false,
                dialogType: DialogType.WARNING,
                animType: AnimType.TOPSLIDE,
                title: "Oyunu sil",
                desc: "Bu oyunu silmek istediğinize emin misiniz?",
              ).show();
            },
            onTap: () {
              NavigationService.navigateWithWidget(
                  GameView(gameModel: game, provider: provider));
            },
            child: Card(
              margin:
                  EdgeInsets.symmetric(horizontal: 0.1.sw, vertical: 0.01.sh),
              child: Container(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Oyun adı: ${game.name}"),
                    Text("Kişi ücreti: ${game.personFee}"),
                    Text("2 kişi ücreti: ${game.personFeeDouble}"),
                    Text("Video ücreti: ${game.videoFee}"),
                    Text("Saatler: ${game.hours.join(",")}"),
                  ],
                ),
              ),
            ),
          );
        },
      )),
    );
  }
}
