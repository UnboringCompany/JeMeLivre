import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:je_me_livre/BookDetailPage.dart';
import 'database_helper.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  String _searchText = '';

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
      _filteredBooks =
          books; // Initialement, la liste filtrée est identique à la liste complète
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _filterBooks(String text) {
    setState(() {
      _searchText = text;
      _filteredBooks = _books
          .where((book) =>
              book['title'].toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group books by authors in the filtered list
    final Map<String, List<Map<String, dynamic>>> booksByAuthor = {};

    for (var book in _filteredBooks) {
      final author = book['author'];
      if (!booksByAuthor.containsKey(author)) {
        booksByAuthor[author] = [];
      }
      booksByAuthor[author]!.add(book);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bibliothèque',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFD2B48C),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Effet boisé en arrière-plan
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
                  onChanged: _filterBooks,
                  decoration: InputDecoration(
                    labelText: 'Rechercher un livre',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              // Utilisation de Expanded pour éviter la zone blanche
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: booksByAuthor.entries.map((entry) {
                      final author = entry.key;
                      final books = entry.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                author,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: books.length,
                                itemBuilder: (context, index) {
                                  final book = books[index];
                                  final isReserved = book['disponible'] == 0;

                                  return GestureDetector(
                                    onTap: isReserved
                                        ? null
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BookDetailPage(book: book),
                                              ),
                                            );
                                          },
                                    child: Container(
                                      width: 120,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        color: isReserved
                                            ? Colors.grey[300]
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 100,
                                            child: Image.asset(
                                              'assets/couverture.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                book['title'],
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isReserved
                                                      ? Colors.grey
                                                      : Colors.black,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        child: const Icon(Icons.add),
      ),
    );
  }
}
