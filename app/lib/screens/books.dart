import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app/classes/profiledata.dart' show ProfileClass;
import 'package:app/storage/secure_storage.dart' show SecureStorage;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/classes/booksdata.dart' show BookClass;

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
  }
}

BookClass book = BookClass();

class Books extends State<BooksState> {
  bool checkedValue = false;
  bool bookFounded = false;
  var bookData = ['Livro1'];

  final TextEditingController foundBooksController = TextEditingController();

  void getBooks() async {
    final token = await SecureStorage.readData('token');
    final response = await http.get(Uri.parse('${dotenv.env['API_URL']}/book/?read=$checkedValue'), headers: {HttpHeaders.authorizationHeader: 'Bearer $token'});

    final responseJson = jsonDecode(response.body);
    final data = responseJson['data'];

    if(responseJson['data'].length == 0){
      setState(() {
        foundBooksController.text = 'None book founded!';
        bookFounded = false;
      });
    }else {
      setState(() {
        foundBooksController.text = 'Achei';
        bookFounded = true;
      });
      
      for(var i = 0; i < data.length; i++){
        print(data[i]['title']);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    
    SecureStorage.readData('avatar').then((value) {
      setState(() {
        profile.setAvatar=value ?? '';
      });
    });

    getBooks();
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
        const SearchState(),
       SizedBox(
          child: Padding(
            padding: const EdgeInsets.only(top: 15, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Checkbox(
                  value: checkedValue,
                  onChanged: (newValue) {
                    setState(() {
                      checkedValue = newValue!;
                    });
                    getBooks();
                  },
                ),
                Text(AppLocalizations.of(context)!.readed),
              ],
            ),
          ),
        ),
        bookFounded == false ? 
        Center(child: Text(foundBooksController.text, style: const TextStyle(fontSize: 16),)) : 
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Container(
            alignment: Alignment.bottomLeft,
            child: Column(
              children: [
                Text('LIVRO AQUI'),
                Text('$bookData')
              ],
            ),
          ),
        )
        ]
      ),
    );
  }
}