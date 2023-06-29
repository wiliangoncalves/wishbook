import 'dart:async';

import 'package:app/screens/login.dart' show LoginState;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RegisterState extends StatefulWidget {
  const RegisterState({super.key});

  @override
  State createState() => Register();
}

class Register extends State<RegisterState> {
  var isValid = false;
  var _firstname = false;
  var _lastname = false;
  var _email = false;
  var _password = false;
  var _confirmPassword = false;

  var messageApi = '';

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future successDialog() async {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return; // Retorna antecipadamente se localizations for nulo
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 50,
          ),
          content: Text(
            localizations.accountSuccess,
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
                gotoLogin()
              },
              child: Center(
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.green,
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

  void register(BuildContext context) async {
    final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/register/'),
        headers: <String, String>{
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          'firstname': firstnameController.text,
          'lastname': lastnameController.text,
          'email': emailController.text,
          'password': passwordController.text
        }));
    if (response.statusCode == 200) {
      setState(() {
        isValid = true;
      });
      successDialog();
    } else {
      setState(() {
        messageApi = json.decode(response.body)['detail'];
      });
      isValid = false;
      return;
    }
  }

  void gotoLogin() {
    if (context.mounted)
      {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const LoginState()));
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
              margin: const EdgeInsets.only(left: 30),
              child: Text(AppLocalizations.of(context)!.register,
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    color: Colors.blue,
                  ))),
          Container(
              margin: const EdgeInsets.only(left: 30, top: 10),
              child: Text(AppLocalizations.of(context)!.registerFields,
                  style: GoogleFonts.lato(
                      fontSize: 20,
                      color: const Color.fromRGBO(75, 75, 78, 0.612)))),
          Container(
            margin: const EdgeInsets.only(left: 30, right: 15, top: 35),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 25.0),
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: firstnameController,
                    onChanged: (value) {
                      if (firstnameController.text.length < 4) {
                        setState(() {
                          _firstname = false;
                        });
                      } else {
                        setState(() {
                          _firstname = true;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      errorText: _firstname == false
                          ? AppLocalizations.of(context)!.firstnameLength
                          : null,
                      labelText: AppLocalizations.of(context)!.firstname,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 15.0),
                  child: TextFormField(
                    controller: lastnameController,
                    onChanged: (value) {
                      if (lastnameController.text.length < 4) {
                        setState(() {
                          _lastname = false;
                        });
                      } else {
                        setState(() {
                          _lastname = true;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      errorText: _lastname == false
                          ? AppLocalizations.of(context)!.lastnameLength
                          : null,
                      labelText: AppLocalizations.of(context)!.lastname,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 15.0),
                  child: TextFormField(
                    controller: emailController,
                    onChanged: (value) {
                      if (RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        setState(() {
                          _email = true;
                        });
                      } else {
                        setState(() {
                          _email = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      errorText: _email == false
                          ? 'Invalid E-mail!'
                          : messageApi == 'E-mail is already in use'
                              ? AppLocalizations.of(context)!.emailUse
                              : null,
                      labelText: 'E-mail',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 15.0),
                  child: TextFormField(
                    obscureText: true,
                    controller: passwordController,
                    onChanged: (value) {
                      RegExp regEx = RegExp(r"(?=.*[a-z])(?=.*[A-Z])\w+");
                      final match = regEx.hasMatch(passwordController.text);

                      if (passwordController.text.length < 8 || match == false) {
                        setState(() {
                          _password = false;
                        });
                      } else {
                        setState(() {
                          _password = true;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      errorText: _password == false
                          ? AppLocalizations.of(context)!.passwordLength
                              : null,
                      labelText: AppLocalizations.of(context)!.password,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 15.0),
                  child: TextFormField(
                    obscureText: true,
                    controller: confirmPasswordController,
                    onChanged: (value) {
                      if (confirmPasswordController.text !=
                          passwordController.text) {
                        setState(() {
                          _confirmPassword = false;
                        });
                      } else {
                        setState(() {
                          _confirmPassword = true;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.confirmPassword,
                      errorText: _confirmPassword == false
                          ? AppLocalizations.of(context)!.confirmPasswordField
                          : null,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 25.0, bottom: 25.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.fromLTRB(50, 10, 50, 10)),
                      onPressed: () => register(context),
                      child: Text(AppLocalizations.of(context)!.register)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.alreadyHaveAccount),
                    Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: InkWell(
                          onTap: () => gotoLogin(),
                          // onTap: () => {
                          //   if (context.mounted)
                          //     {
                          //       Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //               builder: (context) =>
                          //                   const LoginState()))
                          //     }
                          // },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text('Login',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blue)),
                          ),
                        ))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
