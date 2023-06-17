import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

var params =
    jsonEncode({'email': 'mrhumbert@gmail.com', 'password': 'Nada12345'});

void sendLogin() async {
  final response = await http.post(Uri.parse('${dotenv.env['API_URL']}/login/'),
      headers: <String, String>{
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: params);
  print(response.body);
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: Row(
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
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 2.0, top: 100.0),
            child: Column(
              children: [
                const Padding(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(), hintText: 'E-mail'),
                    )),
                // ),
                const Padding(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(), hintText: 'Password'),
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
                        onPressed: sendLogin,
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
                        child: Text(
                          AppLocalizations.of(context)!.signUp,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      )
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
