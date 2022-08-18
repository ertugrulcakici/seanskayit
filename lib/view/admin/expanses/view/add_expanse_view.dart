import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seanskayit/core/utils/extentions/datetime_extentions.dart';
import 'package:seanskayit/core/utils/ui/popup.dart';
import 'package:seanskayit/core/utils/validators.dart';
import 'package:seanskayit/view/admin/expanses/viewmodel/expanses_viewmodel.dart';

class AddExpanseView extends ConsumerStatefulWidget {
  const AddExpanseView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddExpanseViewState();
}

class _AddExpanseViewState extends ConsumerState<AddExpanseView> {
  ChangeNotifierProvider<ExpanseViewModel> provider =
      ChangeNotifierProvider<ExpanseViewModel>((ref) => ExpanseViewModel());

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    ref.read(provider).fillCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpanse,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Gider ekle"),
        actions: [
          TextButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.date_range),
              label: Text(ref.watch(provider).date))
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.1.sw),
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  validator: validateDoubleNecessary,
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Miktar'),
                ),
                TextFormField(
                  onChanged: ref.read(provider).onChanged,
                  validator: validateStringNecessary,
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                ),
                SizedBox(
                  height: 0.4.sh,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ref.watch(provider).filteredCategories.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            ref.watch(provider).filteredCategories[index].name),
                        onTap: () {
                          _categoryController.text = ref
                              .watch(provider)
                              .filteredCategories[index]
                              .name;
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _pickDate() async {
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        locale: const Locale("tr"));
    if (date != null) {
      ref.watch(provider).date = date.toD();
    }
  }

  Future _addExpanse() async {
    if (formKey.currentState!.validate()) {
      String? categoryId =
          await ref.watch(provider).getCategoryId(_categoryController.text);
      if (categoryId == null) {
        await AwesomeDialog(
            context: context,
            title: "Böyle bir kategori yok",
            desc: "Eklemek ister misin ?",
            btnCancelOnPress: () {},
            btnCancelText: "Hayır",
            btnOkOnPress: () async {
              String? newCategoryId = await ref
                  .read(provider)
                  .addCategory(_categoryController.text);
              if (newCategoryId != null) {
                PopupHelper.showSimpleSnackbar("Kategori eklendi",
                    milliSecond: 2000);
                try {
                  double amout = double.parse(
                      _amountController.text.trim().replaceAll(",", "."));
                  if (await ref.read(provider).addExpanse(
                        amount: amout,
                        categoryId: newCategoryId,
                      )) {
                    PopupHelper.showSimpleSnackbar("Gider eklendi");
                    formKey.currentState!.reset();
                    _amountController.text = "";
                    _categoryController.text = "";
                    categoryId = "";
                  } else {
                    PopupHelper.showSimpleSnackbar("Gider eklenemedi");
                  }
                } catch (e) {
                  PopupHelper.showSimpleSnackbar("Gider eklenemedi: $e",
                      error: true);
                }
              } else {
                PopupHelper.showSimpleSnackbar("Kategori eklenemedi",
                    error: true);
              }
            }).show();
      } else {
        double amout =
            double.parse(_amountController.text.trim().replaceAll(",", "."));
        if (await ref.read(provider).addExpanse(
              amount: amout,
              categoryId: categoryId,
            )) {
          PopupHelper.showSimpleSnackbar("Gider eklendi");
          formKey.currentState!.reset();
          _amountController.text = "";
          _categoryController.text = "";
          categoryId = "";
        } else {
          PopupHelper.showSimpleSnackbar("Gider eklenemedi");
        }
      }
    }
  }
}
