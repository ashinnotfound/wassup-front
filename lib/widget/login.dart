import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wassup_front/config/config.dart';
import 'package:wassup_front/request/request.dart';

import '../main.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  LoginDialogState createState() => LoginDialogState();
}

class LoginDialogState extends State<LoginDialog> {
  bool isLogin = true;

  var userNameController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AlertDialog(
      title: const Text("ayo wassup bro🥳🫵🏼"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: userNameController,
            decoration: const InputDecoration(
              labelText: 'Username',
            ),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              isLogin = !isLogin;
            });
          },
          child: Text(isLogin ? '没有账号?' : '已有账号?'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            var userName = userNameController.text;
            var password = passwordController.text;

            try {
              String token = await post(
                  '${Config.authUrl}auth/${isLogin ? 'login' : 'register'}',
                  "",
                  <String, String>{
                    'userName': userName,
                    'password': password,
                  },
                  context) as String;
              if (isLogin) {
                context.read<MyAppState>().login(token, userName);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text(isLogin ? 'Login' : 'Register'),
        ),
      ],
    ));
  }
}
