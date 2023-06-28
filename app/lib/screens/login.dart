import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:app/screens/register.dart' show RegisterState;
import 'package:app/screens/home.dart';

import '../storage/secure_storage.dart' show SecureStorage;

class LoginState extends StatefulWidget {
  const LoginState({super.key});

  @override
  State createState() => Login();
}

class Login extends State<LoginState> {
  var _isValid = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void sendLogin(BuildContext context) async {
    final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/login/'),
        headers: <String, String>{
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text
        }));
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        _isValid = true;
      });
      final token = response.body
          .toString()
          .split(',')[1]
          .toString()
          .split(' ')[1]
          .toString()
          .replaceAll('"', '')
          .toString()
          .replaceAll('}', '');
      await SecureStorage.saveData('token', token);

      if (context.mounted) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Home()));
      }
      return;
    } else {
      _isValid = false;
      await SecureStorage.deleteData('token');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'WISH',
                textScaleFactor: 2.0,
                style: TextStyle(
                    color: Color.fromRGBO(0, 166, 255, 100), fontSize: 16.0),
              ),
              Text(
                'BOOK',
                textScaleFactor: 2.0,
                style: TextStyle(
                    color: Color.fromRGBO(52, 63, 75, 100), fontSize: 16.0),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 2.0, top: 100.0),
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (value) {
                        if (RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                          setState(() {
                            _isValid = true;
                          });
                        } else {
                          setState(() {
                            _isValid = false;
                          });
                        }
                      },
                      controller: emailController,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          errorBorder: const UnderlineInputBorder(),
                          errorText: _isValid == true
                              ? null
                              : AppLocalizations.of(context)!.fillOutEmail,
                          hintText: 'E-mail'),
                    )),
                // ),
                Padding(
                    padding: const EdgeInsets.all(15),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: AppLocalizations.of(context)!.password),
                    )),

                Container(
                  margin: const EdgeInsets.only(top: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(AppLocalizations.of(context)!.forgotPassword)
                      ]),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10)),
                        onPressed: () => sendLogin(context),
                        child: const Text('LOGIN')),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.createAccount),
                      Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: InkWell(
                            onTap: () => {
                              if (context.mounted)
                                {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterState()))
                                }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(AppLocalizations.of(context)!.signUp,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.blue)),
                            ),
                          ))
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
