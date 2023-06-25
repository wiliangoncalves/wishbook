import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:app/screens/login.dart' show LoginState;
import 'package:app/screens/home.dart' show Home;

class RegisterState extends StatefulWidget {
  const RegisterState({super.key});

  @override
  State createState() => Register();
}

class Register extends State<RegisterState> {
  var _isvalid = false;
  var _firstname = false;
  var _lastname = false;
  var _email = false;
  var _password = false;
  var _confirmPassword = false;

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
        _isvalid = true;
      });
      if (context.mounted) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Home()));
      }
    } else {
      print(response.body);
      _isvalid = false;
      return;
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
                      errorText: _email == false ? 'Invalid E-mail!' : null,
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
                      if (passwordController.text.length < 8) {
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
                          onTap: () => {
                            if (context.mounted)
                              {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginState()))
                              }
                          },
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
