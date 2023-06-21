import 'package:flutter/material.dart';

class RegisterState extends StatefulWidget {
  const RegisterState({super.key});

  @override
  State createState() => Register();
}

class Register extends State<RegisterState> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const Text('REGISTER'),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'))
        ],
      ),
    );
  }
}
