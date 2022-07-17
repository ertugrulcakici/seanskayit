import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seanskayit/core/services/navigation/navigation_service.dart';
import 'package:seanskayit/product/models/user_model.dart';
import 'package:seanskayit/view/admin/users/view/user_view.dart';
import 'package:seanskayit/view/admin/users/viewmodel/users_viewmodel.dart';

class UsersView extends ConsumerStatefulWidget {
  const UsersView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UsersViewState();
}

class _UsersViewState extends ConsumerState<UsersView> {
  ChangeNotifierProvider<UserViewModel> provider =
      ChangeNotifierProvider<UserViewModel>((_) => UserViewModel());

  @override
  void initState() {
    ref.read(provider).fillUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kullanıcı listesi")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          NavigationService.navigateWithWidget(UserView(provider: provider));
        },
      ),
      body: Center(
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: ref.watch(provider).users.length,
            itemBuilder: (context, index) {
              UserModel user = ref.watch(provider).users[index];
              return Card(
                child: ListTile(
                  title: Text("İsim: ${user.name}"),
                  subtitle: Text(
                      "Şifresi: ${user.password}\nSon giriş yapma tarihi: ${user.lastLogin}"),
                  leading: const Icon(Icons.person),
                  trailing: Checkbox(
                      value: user.active,
                      onChanged: (value) async {
                        user.active = value ?? false;
                        await ref.read(provider).editUser(user.toJson());
                      }),
                  onTap: () {
                    NavigationService.navigateWithWidget(
                        UserView(userModel: user, provider: provider));
                  },
                ),
              );
            }),
      ),
    );
  }
}
