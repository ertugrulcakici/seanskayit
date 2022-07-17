import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seanskayit/core/services/cache/locale_manager.dart';
import 'package:seanskayit/core/services/firebase/auth_service.dart';
import 'package:seanskayit/core/services/navigation/navigation_service.dart';
import 'package:seanskayit/core/utils/datetime_extentions.dart';
import 'package:seanskayit/product/enums/locale_enums.dart';
import 'package:seanskayit/product/enums/navigation_enums.dart';
import 'package:seanskayit/product/models/session_model.dart';
import 'package:seanskayit/view/home/view/session_view.dart';
import 'package:seanskayit/view/home/viewmodel/home_viewmodel.dart';
import 'package:seo_renderer/renderers/text_renderer/text_renderer_style.dart';
import 'package:seo_renderer/renderers/text_renderer/text_renderer_vm.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  late ChangeNotifierProvider<HomeViewModel> provider =
      ChangeNotifierProvider<HomeViewModel>(((ref) => HomeViewModel()));

  @override
  void initState() {
    ref.read(provider).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _drawer(),
      appBar: _appBar(),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_games(), _sessions()]),
    );
  }

  Widget _sessions() {
    return Expanded(
      child: GridView.builder(
          itemCount: ref.watch(provider).selectedGame != null
              ? ref.watch(provider).selectedGame!.hours.length + 1
              : 0,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  ScreenUtil().orientation == Orientation.portrait ? 2 : 5,
              childAspectRatio: 1.0),
          itemBuilder: (context, index) {
            if (index == ref.watch(provider).selectedGame!.hours.length) {
              return Center(
                  child: Text(
                      "Toplam kişi: ${ref.watch(provider).totalCount}\nToplam video: ${ref.watch(provider).totalVideoCount}${ref.watch(provider).totalExtraCount > 0 ? "\nToplam ekstra: ${ref.watch(provider).totalExtraCount}" : ""}${ref.watch(provider).totalDiscountCount > 0 ? "\nToplam indirim: ${ref.watch(provider).totalDiscountCount}" : ""}"));
            }
            String hour = ref.watch(provider).selectedGame!.hours[index];
            String currentHour = DateTime.now().H;
            bool passed = false;
            if (int.parse(hour.split(":")[0]) <
                int.parse(currentHour.split(":")[0])) {
              passed = true;
            } else if ((int.parse(hour.split(":")[0]) ==
                    int.parse(currentHour.split(":")[0])) &&
                (int.parse(hour.split(":")[1]) <
                    int.parse(currentHour.split(":")[1]))) {
              passed = true;
            }
            SessionModel? session = ref.watch(provider).sessions[index];
            String desc = "";
            if (session != null) {
              desc += "Kişi sayısı: ${session.count}\n";
              desc += "Video: ${session.video ? "var" : "yok"}\n";
              if (session.name != null) {
                desc += "İsim: ${session.name!}\n";
              }
              if (session.phone != null) {
                desc += "Telefon: ${session.phone!}\n";
              }
              if (session.discount != null) {
                desc += "İndirim: ${session.discount!}\n";
              }
              if (session.extra != null) {
                desc += "Ekstra: ${session.extra!}\n";
              }
              if (session.note != null) {
                desc += "Not: ${session.note!}\n";
              }
              desc +=
                  "Ekleyen kullanıcı: ${ref.watch(provider).users.firstWhere((element) => element.id == session.addedBy).name}\n";
            }

            return InkWell(
              child: Container(
                margin: EdgeInsets.all(0.01.sw),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                            color: session == null
                                ? Colors.grey
                                : passed
                                    ? Colors.red
                                    : Colors.green,
                          ),
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              "Saat: $hour",
                              style: const TextStyle(color: Colors.white),
                            ),
                          )),
                    ),
                    Expanded(
                      flex: 4,
                      child: Center(child: Text(desc)),
                    )
                  ],
                ),
              ),
              onTap: () {
                NavigationService.navigateWithWidget(SessionView(
                    provider: provider, index: index, session: session));
              },
            );
          }),
    );
  }

  Card _games() {
    return Card(
      child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ref
                  .watch(provider)
                  .games
                  .map((e) => Expanded(
                        child: TextButton(
                            style: TextButton.styleFrom(primary: Colors.black),
                            onPressed: () {
                              ref.read(provider).selectedGame = e;
                            },
                            child: Text(e.name,
                                style: TextStyle(
                                    fontSize: ScreenUtil().orientation ==
                                            Orientation.landscape
                                        ? 10.sp
                                        : 15.sp,
                                    color:
                                        ref.watch(provider).selectedGame?.id ==
                                                e.id
                                            ? Colors.black
                                            : Colors.grey))),
                      ))
                  .toList())),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextRenderer(
              text: ref.watch(provider).date,
              style: TextRendererStyle.paragraph,
              child: Text(ref.watch(provider).date)),
          SizedBox(width: 0.01.sw),
          IconButton(
              onPressed: _selectDate, icon: const Icon(Icons.calendar_today)),
        ],
      ),
      centerTitle: true,
    );
  }

  Drawer _drawer() {
    return Drawer(
      backgroundColor: Colors.grey.shade100,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ListTile(
            trailing: const Icon(Icons.account_box_outlined),
            title: Text(AuthService.instance.currentUser.name)),
        ListTile(
            onTap: () {
              NavigationService.navigateToPage(NavigationEnums.addExpanse);
            },
            trailing: const Icon(Icons.add),
            title: const Text("Gider Ekle")),
        ListTile(
          title: Text(
              "Versiyon: ${LocaleManager.instance.getInt(LocaleEnum.appVer)}"),
        ),
        Visibility(
            visible: AuthService.instance.currentUser.isAdmin,
            child: ExpansionTile(
                initiallyExpanded: true,
                title: const Text("Admin"),
                children: [
                  ListTile(
                      onTap: () => NavigationService.navigateToPage(
                          NavigationEnums.expanses),
                      trailing: const Icon(Icons.money_off),
                      title: const Text("Giderler")),
                  ListTile(
                      onTap: () => NavigationService.navigateToPage(
                          NavigationEnums.statistics),
                      trailing: const Icon(Icons.bar_chart),
                      title: const Text("İstatistikler")),
                  ListTile(
                      onTap: () => NavigationService.navigateToPage(
                          NavigationEnums.users),
                      trailing: const Icon(Icons.manage_accounts),
                      title: const Text("Kullanıcıları gör")),
                  ListTile(
                      onTap: () => NavigationService.navigateToPage(
                          NavigationEnums.games),
                      trailing: const Icon(Icons.gamepad),
                      title: const Text("Oyunları gör")),
                  ListTile(
                    onTap: () => NavigationService.navigateToPage(
                        NavigationEnums.sessionHistory),
                    trailing: const Icon(Icons.history),
                    title: const Text("Seans kayıtlarını gör"),
                  )
                ]))
      ]),
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
}
