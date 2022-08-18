import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seanskayit/core/utils/extentions/datetime_extentions.dart';
import 'package:seanskayit/product/models/expanse_model.dart';
import 'package:seanskayit/view/admin/expanses/viewmodel/expanses_viewmodel.dart';

class ExpansesView extends ConsumerStatefulWidget {
  const ExpansesView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpansesViewState();
}

class _ExpansesViewState extends ConsumerState<ExpansesView> {
  ChangeNotifierProvider<ExpanseViewModel> provider =
      ChangeNotifierProvider<ExpanseViewModel>(
    (ref) => ExpanseViewModel(),
  );

  @override
  void initState() {
    ref.read(provider).fillUsers().then((value) {
      ref.read(provider).fillCategories().then((value) {
        ref.read(provider).fillExpanses();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(provider).deneme();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(ref.watch(provider).date),
            IconButton(
                onPressed: _pickDate, icon: const Icon(Icons.date_range)),
            Text("Toplam: ${ref.watch(provider).total}"),
          ],
        ),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: ref.watch(provider).expanses.length,
            itemBuilder: (context, index) {
              ExpanseModel expanse = ref.watch(provider).expanses[index];
              String subtitle = "";
              subtitle +=
                  "Kategoris: ${ref.watch(provider).categories.where((element) => element.id == expanse.categoryId).first.name}";
              subtitle +=
                  "\nEkleyen: ${ref.watch(provider).users.where((element) => expanse.addedBy == element.id).first.name}";
              return Card(
                child: ListTile(
                  title: Text(expanse.amount.toString()),
                  subtitle: Text(subtitle),
                  onLongPress: () async {
                    AwesomeDialog(
                      context: context,
                      title: "Gideri sil",
                      btnCancelOnPress: () {},
                      btnOkOnPress: () async {
                        await ref.read(provider).deleteExpanse(expanse);
                      },
                      btnOkText: "Evet",
                      btnCancelText: "Hayır",
                    ).show();
                  },
                ),
              );
            }),
      ),
    );
  }

  void _pickDate() async {
    DateTime? datetime = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
    if (datetime != null) {
      ref.watch(provider).date = datetime.toD();
      ref.watch(provider).fillExpanses();
    }
  }
}
