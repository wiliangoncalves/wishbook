import 'package:flutter/material.dart';
import 'package:app/screens/home.dart' show HomeState;
import 'package:app/screens/profile.dart' show ProfileState;
import 'package:app/screens/profile.dart' show getProfile;
import 'package:app/screens/books.dart' show BooksState;

class BottomNavigatorBarState extends StatefulWidget {
  const BottomNavigatorBarState({super.key});

  @override
  State createState() => BottomNavigatorBar();
}

class BottomNavigatorBar extends State<BottomNavigatorBarState> {
  int _selectedIndex = 0;

  void _onTappedItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeState(),
    const BooksState(),
    const Text('Collections'),
    const ProfileState(),
  ];

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    getProfile();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.blueGrey
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
            backgroundColor: Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark),
            label: 'Collections',
            backgroundColor: Colors.blueGrey
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.blueGrey,
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 6, 63, 92),
        onTap: _onTappedItem,
      ),
    ));
  }
}