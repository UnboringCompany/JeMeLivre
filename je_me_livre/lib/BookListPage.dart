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
    // Group books by authors
    final Map<String, List<Map<String, dynamic>>> booksByAuthor = {};

    // Regrouper les livres par auteur
    for (var book in _books) {
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
            color: Colors.black, // Texte noir pour un meilleur contraste
          ),
        ),
        backgroundColor:
            Color(0xFFD2B48C), // Marron clair en accord avec le bois
        elevation: 0, // Pas d'ombre sous l'AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            onPressed: _deleteAllBooks,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Effet boisé en arrière-plan (nouvelle image pour le fond)
          Positioned.fill(
            child: Image.asset(
              'assets/wood_background.jpg', // Image de fond boisé
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: booksByAuthor.entries.map((entry) {
                final author = entry.key;
                final books = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Noms des auteurs avec un simple texte noir
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          author,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Couleur du texte des auteurs
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            180, // Ajuste la hauteur pour afficher correctement les couvertures des livres
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
                              onLongPress: () async {
                                await _showDeleteConfirmationDialog(book['id']);
                              },
                              child: Container(
                                width:
                                    120, // Largeur pour chaque carte de livre
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                  color: isReserved
                                      ? Colors.grey[300]
                                      : Colors.white,
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
                                    // Image à la place du cadre blanc
                                    Container(
                                      height:
                                          100, // Ajuster la hauteur pour l'image
                                      child: Image.asset(
                                        'assets/couverture.png', // Image à utiliser pour le cadre
                                        fit: BoxFit
                                            .cover, // S'assurer que l'image couvre bien tout l'espace
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          book['title'],
                                          textAlign: TextAlign.center,
                                          maxLines:
                                              2, // Limite à 2 lignes pour éviter le débordement
                                          overflow: TextOverflow
                                              .ellipsis, // Ajouter des points si le texte est trop long
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        child: Icon(Icons.add),
      ),
    );
  }
}
