import 'package:flutter/material.dart';
import 'package:seanskayit/core/services/firebase/auth_service.dart';
import 'package:seanskayit/core/services/navigation/navigation_service.dart';
import 'package:seanskayit/product/enums/navigation_enums.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: ListTile(
            title: TextField(
              onSubmitted: (String value) async {
                if (await AuthService.instance
                    .login(_textEditingController.text)) {
                  NavigationService.navigateToPageClearStack(
                      NavigationEnums.home);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Şifre hatalı")));
                }
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: 'Şifre',
              ),
              controller: _textEditingController,
            ),
            trailing: IconButton(
                onPressed: () async {
                  if (await AuthService.instance
                      .login(_textEditingController.text)) {
                    NavigationService.navigateToPageClearStack(
                        NavigationEnums.home);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Şifre hatalı")));
                  }
                },
                icon: const Icon(Icons.arrow_forward_ios)),
          ),
        ),
      ),
    );
  }
}
