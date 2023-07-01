import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:app/screens/register.dart' show RegisterState;
import 'package:app/src/bottomnavigatorbar.dart' show BottomNavigatorBarState;

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

  Future verifyEmailDialog() async {
    return showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Icon(
          Icons.warning_amber_sharp,
          color: Colors.orange,
          size: 50.0,
        ),
        actions: [
          TextButton(onPressed: () => {
            Navigator.pop(context)
          }, child: Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Ok',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),)
        ],
      );
    });
  }

  Future emailOrPassDialog() async {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return; // Retorna antecipadamente se localizations for nulo
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(
            Icons.warning_amber,
            color: Colors.orange,
            size: 50,
          ),
          content: Text(
            localizations.emailOrPass,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: [
            TextButton(
              onPressed: () => {
                Navigator.of(context).pop(),
              },
              child: Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Ok',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

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

    if(response.statusCode == 400 && json.decode(response.body)['detail'] == 'Please, verify your e-mail'){
      verifyEmailDialog();
    }
    if(response.statusCode == 400 && json.decode(response.body)['detail'] == 'E-mail or password is incorrect!'){
      emailOrPassDialog();
    }
    if (response.statusCode == 200) {
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

      if(context.mounted){
        Navigator
      .of(context)
        .pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const BottomNavigatorBarState()
        )
       );
      }
      // if (context.mounted) {
      //   Navigator.push(
      //       context, MaterialPageRoute(builder: (context) => const BottomNavigatorBarState()));
      // }
      return;
    } else {
      await SecureStorage.deleteData('token');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                          errorText: _isValid == false ? AppLocalizations.of(context)!.fillOutEmail: null,
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
