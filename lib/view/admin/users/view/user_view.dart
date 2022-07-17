import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seanskayit/core/utils/ui/popup.dart';
import 'package:seanskayit/product/models/user_model.dart';
import 'package:seanskayit/view/admin/users/viewmodel/users_viewmodel.dart';

class UserView extends ConsumerStatefulWidget {
  UserModel? userModel;
  ChangeNotifierProvider<UserViewModel> provider;

  UserView({Key? key, this.userModel, required this.provider})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserViewState();
}

class _UserViewState extends ConsumerState<UserView> {
  Map<String, dynamic> data = {
    "active": true,
    "isAdmin": false,
    "name": "",
    "password": ""
  };
  GlobalKey<FormFieldState> formKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    if (widget.userModel != null) {
      data = widget.userModel!.toJson();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kullanıcı Düzenle"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          if (widget.userModel == null) {
            if (await ref.read(widget.provider).addUser(data)) {
              PopupHelper.showSimpleSnackbar("Kullanıcı eklendi");
              Navigator.pop(context);
            } else {
              PopupHelper.showSimpleSnackbar("Kullanıcı eklenemedi");
              formKey.currentState!.reset();
            }
          } else {
            if (await ref.read(widget.provider).editUser(data)) {
              PopupHelper.showSimpleSnackbar("Kullanıcı düzenlendi");
              Navigator.pop(context);
            } else {
              PopupHelper.showSimpleSnackbar("Kullanıcı düzenlenemedi");
              formKey.currentState!.reset();
            }
          }
        },
      ),
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                initialValue: data["name"],
                decoration: const InputDecoration(label: Text("İsim")),
                onChanged: (value) {
                  data["name"] = value;
                },
              ),
              TextFormField(
                initialValue: data["password"],
                decoration: const InputDecoration(label: Text("Şifre")),
                onChanged: (value) {
                  data["password"] = value;
                },
              ),
              SwitchListTile(
                title: const Text("Admin"),
                value: data["isAdmin"],
                onChanged: (value) {
                  setState(() {
                    data["isAdmin"] = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
