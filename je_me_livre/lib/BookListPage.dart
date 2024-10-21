import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:je_me_livre/BookDetailPage.dart';
import 'database_helper.dart';

class BookListPage extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadBooksFromJson();
  }

  Future<void> _loadBooks() async {
    final books = await _dbHelper.getBooks();
    setState(() {
      _books = books;
    });
  }

  Future<void> _loadBooksFromJson() async {
    final jsonString = await rootBundle.loadString('assets/MesLivres.json');
    final jsonData = jsonDecode(jsonString);

    for (var book in jsonData) {
      final row = {
        'title': book['title'],
        'author': book['author'],
        'description': book['description'],
        'disponible': book['disponible'] ? 1 : 0,
      };
      await _dbHelper.insertBook(row);
    }

    _loadBooks();
  }

  Future<void> _addBook() async {
    final title = await _showInputDialog('Title');
    final author = await _showInputDialog('Author');

    if (title != null && author != null) {
      final row = {
        'title': title,
        'author': author,
      };
      await _dbHelper.insertBook(row);
      _loadBooks();
    }
  }

  Future<String?> _showInputDialog(String label) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter $label'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(int bookId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this book?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _dbHelper.deleteBook(bookId);
      _loadBooks();
    }
  }

  Future<void> _deleteAllBooks() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete all books?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _dbHelper.deleteAllBooks();
      _loadBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteAllBooks,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          final isReserved = book['disponible'] == 0;
          return ListTile(
            title: Text(
              book['title'],
              style: TextStyle(
                color: isReserved ? Colors.grey : Colors.black,
              ),
            ),
            subtitle: Text(
              '${book['author']}',
              style: TextStyle(
                color: isReserved ? Colors.grey : Colors.black,
              ),
            ),
            onTap: isReserved
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailPage(book: book),
                      ),
                    );
                  },
            onLongPress: () async {
              await _showDeleteConfirmationDialog(book['id']);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        child: Icon(Icons.add),
      ),
    );
  }
}



