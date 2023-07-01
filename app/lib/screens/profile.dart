import 'package:flutter/material.dart';

class ProfileState extends StatefulWidget {
  const ProfileState({super.key});

  @override
  State createState () => Profile();
}

class Profile extends State<ProfileState> {
  @override
  Widget build(BuildContext context) {
    return const  Scaffold(
      body: Text('PROFILE'),
    );
  }
}

// class Profile extends StatelessWidget {
//   const Profile({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const  Scaffold(
//       body: Text('PROFILE'),
//     );
//   }
// }