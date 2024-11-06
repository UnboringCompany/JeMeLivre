import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'BookListPage.dart';
import 'ReservationHistoryPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to Personal Library',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReservationHistoryPage()),
              );
            },
            child: const Text('View Reservation'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookListPage()),
              );
            },
            child: const Text('View Library'),
          ),
        ],
      ),
    );
  }
}
