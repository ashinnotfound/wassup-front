import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wassup_front/config.dart';

import 'main.dart';

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

            await http
                .post(
                  Uri.parse(
                      '${Config.authUrl}auth/${isLogin ? 'login' : 'register'}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json;charset=UTF-8',
                  },
                  body: jsonEncode(<String, String>{
                    'userName': userName,
                    'password': password,
                  }),
                )
                .then((value) => {
                      if (value.statusCode == 200)
                        {
                          if (jsonDecode(value.body)['code'] == 200)
                            {
                              if (isLogin)
                                {
                                  context.read<MyAppState>().login(
                                      jsonDecode(value.body)['data'], userName),
                                },
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(jsonDecode(value.body)['message']),
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            }
                          else
                            {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(jsonDecode(value.body)['message']),
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            }
                        }
                      else
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('网络错误'),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        }
                    });
          },
          child: Text(isLogin ? 'Login' : 'Register'),
        ),
      ],
    ));
  }
}
