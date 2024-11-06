import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:je_me_livre/BookDetailPage.dart';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookListPage extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListPage> with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  String _searchText = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final prefs = await SharedPreferences.getInstance();
    bool isInitialized = prefs.getBool('Initialized') ?? false;

    if (!isInitialized) {
      await _loadBooksFromJson();
      await prefs.setBool('Initialized', true);
    }
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await _dbHelper.getBooks();
    setState(() {
      _books = books;
      _filteredBooks = books;
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

  Future<void> _clearDatabase() async {
    await _dbHelper.deleteAllBooks();
    _loadBooks();
  }

  Future<String?> _showInputDialog(String label) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Color(0xFFD2B48C), // Couleur de fond personnalisée
        title: Text(
          'Enter $label',
          style: TextStyle(
            color: Color.fromARGB(255, 250, 237, 247), // Couleur du texte
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Color.fromARGB(255, 250, 237, 247), // Couleur du texte du label
            ),
          ),
          style: TextStyle(
            color: Color.fromARGB(255, 250, 237, 247), // Couleur du texte saisi
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Color.fromARGB(255, 250, 237, 247)), // Couleur du texte du bouton
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(
              'OK',
              style: TextStyle(color: Color.fromARGB(255, 250, 237, 247)), // Couleur du texte du bouton
            ),
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

  Widget _buildBookItem(Map<String, dynamic> book) {
    final isReserved = book['disponible'] == 0;

    return FadeTransition(
      opacity: _animationController,
      child: GestureDetector(
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
        child: Container(
          width: 120,
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: isReserved ? Colors.grey[300] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                child: Image.asset(
                  'assets/couverture.png',
                  fit: BoxFit.cover,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    book['title'],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isReserved ? Colors.grey : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Bibliothèque',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFFD2B48C),
        elevation: 0,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.delete),
        //     onPressed: _clearDatabase,
        //     tooltip: 'Supprimer tous les livres',
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/wood_background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: _filterBooks,
                  decoration: InputDecoration(
                    labelText: 'Rechercher un livre',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
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
                                style: TextStyle(
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
                                  return _buildBookItem(books[index]);
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
      floatingActionButton: ScaleTransition(
        scale: Tween(begin: 1.0, end: 1.2)
            .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)),
        child: FloatingActionButton(
          onPressed: () {
            _animationController.reverse().then((value) => _animationController.forward());
            _addBook();
          },
          backgroundColor: Color(0xFFD2B48C),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

