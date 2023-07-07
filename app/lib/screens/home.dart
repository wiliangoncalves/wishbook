import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:app/profileclasses/profiledata.dart' show ProfileClass;

class HomeState extends StatefulWidget {
  const HomeState({super.key});

  @override
  State createState () => Home();
}

class Home extends State<HomeState> {
  ProfileClass profile = ProfileClass();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('READING NOW', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Image.network(profile.getAvatar == '' ?
                  'https://i.ibb.co/MPGG9nn/avatar.jpg' : profile.getAvatar,
                  height: 50,
                  scale: 1,),
              ],
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              const Text('Julius Evola', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: 
                  Column(
                    children: [
                      Image.network('https://i.ibb.co/ZzTkxb5/evola.jpg', height: 300,  width: 300),
                      Container(
                        margin: const EdgeInsets.only(top: 30),
                        child: const Column(
                          children: [
                            Text('O guia completo introdução á magia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                            Divider(color: Colors.red),
                          ],
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              child: const Text(
                              'Description:',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            ),
                            const Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas ornare sollicitudin pellentesque. Phasellus eget tempor tellus, in varius velit. Nulla sagittis egestas ligula nec suscipit. In blandit eget nulla molestie bibendum. Nulla facilisi. Donec imperdiet eros magna, ornare porta ipsum laoreet eget. Nulla sed turpis quis justo sollicitudin fringilla ac sed lorem. Nullam ut massa quis tellus mattis venenatis. Pellentesque interdum elementum enim. Quisque convallis tincidunt massa, quis ornare neque maximus et. Nulla sed quam lacus. Vivamus eleifend mauris leo, eu sodales sapien interdum sit amet.',
                            ),
                          ],
                        ),
                      )
                    ],
                )
              )
            ],
          ),
        )
      ]),
    );
  }
}
