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
  }

  Future<void> _loadBooks() async {
    final books = await _dbHelper.getBooks();
    setState(() {
      _books = books;
    });
  }

  Future<void> _addBook() async {
    final title = await _showInputDialog('Title');
    final author = await _showInputDialog('Author');
    final genre = await _showInputDialog('Genre');

    if (title != null && author != null && genre != null) {
      final row = {
        'title': title,
        'author': author,
        'genre': genre,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library'),
      ),
      body: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return ListTile(
            title: Text(book['title']),
            subtitle: Text('${book['author']} - ${book['genre']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailPage(book: book),
                ),
              );
            },
            onLongPress: () async {
              await _dbHelper.deleteBook(book['id']);
              _loadBooks();
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
