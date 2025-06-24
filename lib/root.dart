import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ponder_app/pages/add/add.dart';
import 'package:ponder_app/pages/auth/auth.dart';
import 'package:ponder_app/pages/home/homePage.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key, this.credential});

  final dynamic credential;

  @override
  State<RootPage> createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  RootPageState({credential = ''});
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    HomePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser == null) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                body: _widgetOptions.elementAt(_selectedIndex),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: FloatingActionButton(
                  shape: CircleBorder(),
                  backgroundColor: const Color.fromARGB(255, 131, 184, 189),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddPage()),
                    );
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
                bottomNavigationBar: BottomAppBar(
                  color: const Color.fromARGB(255, 166, 227, 233),
                  shape: CircularNotchedRectangle(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () => _onItemTapped(0),
                          icon: Icon(Icons.home, color: Colors.white)),
                      IconButton(
                          onPressed: () => _onItemTapped(0),
                          icon: Icon(Icons.settings, color: Colors.white)),
                    ],
                  ),
                ));
          } else {
            return Authentication();
          }
        });
  }
}
