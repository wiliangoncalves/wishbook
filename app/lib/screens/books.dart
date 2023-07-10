import 'package:flutter/material.dart';
import 'package:app/profileclasses/profiledata.dart' show ProfileClass;
import 'package:app/storage/secure_storage.dart' show SecureStorage;

class BooksState extends StatefulWidget {
  const BooksState({super.key});

  @override
  State createState () => Books();
}

class SearchState extends StatefulWidget {
  const SearchState({super.key});

  @override
  State createState () => SearchInput();
}

class SearchInput extends State<SearchState> {
  @override
    Widget build(BuildContext context) {
      return 
      Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 15),
            child: Material(
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: TextField(
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Flexible(
      //       flex: 1,
      //       child: Padding(
      //         padding: const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 15),
      //         child: Material(
      //           elevation: 3,
      //           // shadowColor: Colors.blue,
      //           child:
      //           TextField(
      //           cursorColor: Colors.grey,
      //           decoration: InputDecoration(
      //             contentPadding: const EdgeInsets.all(0),
      //             border: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(5),
      //               borderSide: BorderSide.none,
      //             ),
      //             hintText: 'Search',
      //             hintStyle: TextStyle(
      //               color: Colors.grey,
      //               fontSize: 18
      //             ),
      //             prefixIcon: Icon(Icons.search)
      //           ),
      //         )),
      //       ),
      //     ),
      //   ],
      // );
    }
}

class Books extends State<BooksState> {
  @override
  void initState() {
    super.initState();
    
    SecureStorage.readData('avatar').then((value) {
      setState(() {
        profile.setAvatar=value ?? '';
      });
    });
  }
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
                const Text('BOOKS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    profile.getAvatar == '' ?
                    'https://i.ibb.co/MPGG9nn/avatar.jpg' : profile.getAvatar,
                    height: 60,
                    scale: 1,
                  ),
                )
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
          child: SearchState(),
        )
      ]),
    );
  }
}
