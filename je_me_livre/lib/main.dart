import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'BookListPage.dart';
import 'ReservationHistoryPage.dart';
import 'HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Library',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // HomePage(),
    BookListPage(),
    ReservationHistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal Library',
          style: TextStyle(
            color: Colors.black, // Texte noir pour un meilleur contraste
          ),
        ),
        backgroundColor:
            Color(0xFFD2B48C), // Marron clair en accord avec le bois
        elevation: 0, // Pas d'ombre sous l'AppBar
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.home),
          //   label: 'Home',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Reservation',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 250, 237, 247),
        onTap: _onItemTapped,
        backgroundColor:
            Color(0xFFD2B48C), // Marron clair en accord avec le bois
        elevation: 0, // Pas d'ombre sous l'AppBar
      ),
    );
  }
}
