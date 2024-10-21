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

  @override
  void initState() {
    super.initState();
    _loadReservedBooks();
  }

  Future<void> _loadReservedBooks() async {
    final reservedBooks = await _dbHelper.getReservedBooks();
    setState(() {
      _reservedBooks = reservedBooks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation'),
      ),
      body: ListView.builder(
        itemCount: _reservedBooks.length,
        itemBuilder: (context, index) {
          final book = _reservedBooks[index];
          return ListTile(
            title: Text(book['title']),
            subtitle: Text('Author: ${book['author']}\nReservation Date: ${book['reservation_start_date']}'),
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
    );
  }
}


