import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'BookDetailPage.dart';

class ReservationHistoryPage extends StatefulWidget {
  @override
  _ReservationHistoryPageState createState() => _ReservationHistoryPageState();
}

class _ReservationHistoryPageState extends State<ReservationHistoryPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _reservedBooks = [];
  List<Map<String, dynamic>> _filteredReservedBooks = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadReservedBooks();
  }

  Future<void> _loadReservedBooks() async {
    final reservedBooks = await _dbHelper.getReservedBooks();
    setState(() {
      _reservedBooks = reservedBooks;
      _filteredReservedBooks = reservedBooks; // Initialiser la liste filtrée
    });
  }

  void _filterReservedBooks(String text) {
    setState(() {
      _searchText = text;
      _filteredReservedBooks = _reservedBooks
          .where((book) =>
              book['title'].toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Réservation',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor:
            Color(0xFFD2B48C), // Marron clair pour s'accorder au bois
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Fond bois sur toute la hauteur
          Positioned.fill(
            child: Image.asset(
              'assets/wood_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              // Champ de recherche
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: _filterReservedBooks,
                  decoration: InputDecoration(
                    labelText: 'Rechercher une réservation',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              // Liste des réservations filtrées
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredReservedBooks.length,
                  itemBuilder: (context, index) {
                    final book = _filteredReservedBooks[index];
                    return ListTile(
                      title: Text(
                        book['title'],
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Auteur : ${book['author']}\nDate de réservation : ${book['reservation_start_date']}',
                        style: TextStyle(color: Colors.black87),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailPage(book: book),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
