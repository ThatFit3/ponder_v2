import 'package:flutter/material.dart';
import 'package:ponder_app/main.dart';
import 'package:ponder_app/pages/homePage.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key, this.credential});

  final dynamic credential;

  @override
  State<RootPage> createState() => RootPageState();
}

class RootPageState extends State<RootPage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    homePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: const Color.fromARGB(255, 131, 184, 189),
          onPressed: () {
            keys.add("New");
            Navigator.pushReplacement(
              // forces rebuild
              context,
              MaterialPageRoute(builder: (context) => RootPage()),
            ); // return a signal to rebuild
          },
          child: Icon(Icons.add),
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
  }
}
