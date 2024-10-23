import 'package:flutter/material.dart';
import 'database_helper.dart';

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;

  BookDetailPage({required this.book});

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _toggleReservation() async {
    final bookId = widget.book['id'];
    final isAvailable = widget.book['disponible'] == 1;
    final reservationStartDate = isAvailable ? DateTime.now().toString() : null;

    await _dbHelper.updateBookAvailability(
        bookId, !isAvailable, reservationStartDate);

    setState(() {
      widget.book['disponible'] = isAvailable ? 0 : 1;
      widget.book['reservation_start_date'] = reservationStartDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${widget.book['title']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Author: ${widget.book['author']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Description: ${widget.book['description']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleReservation,
              child: Text(
                widget.book['disponible'] == 1
                    ? 'Reserve'
                    : 'Cancel Reservation',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
