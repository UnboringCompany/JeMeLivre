import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'BookListPage.dart';
import 'ReservationHistoryPage.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to Personal Library',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservationHistoryPage()),
              );
            },
            child: Text('View Reservation'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookListPage()),
              );
            },
            child: Text('View Library'),
          ),
        ],
      ),
    );
  }
}
