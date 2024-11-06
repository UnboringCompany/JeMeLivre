import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'BookListPage.dart';
import 'ReservationHistoryPage.dart';
import 'package:confetti/confetti.dart';  // Import du package confetti

class BookDetailPage extends StatefulWidget {
  final Map<String, dynamic> book;

  BookDetailPage({required this.book});

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late AnimationController _animationController;
  late Map<String, dynamic> _bookData;

  // Controller pour gérer les confettis
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.2,
    );

    // Initialisation du contrôleur de confettis
    _confettiController = ConfettiController(duration: Duration(seconds: 2));

    // Crée une copie modifiable de widget.book
    _bookData = Map<String, dynamic>.from(widget.book);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();  // Dispose du contrôleur de confettis
    super.dispose();
  }

  Future<void> _toggleReservation() async {
    final bookId = _bookData['id'];
    final isAvailable = _bookData['disponible'] == 1;
    final reservationStartDate = isAvailable ? DateTime.now().toString() : null;

    await _dbHelper.updateBookAvailability(
      bookId,
      !isAvailable,
      reservationStartDate,
    );

    setState(() {
      _bookData['disponible'] = isAvailable ? 0 : 1;
      _bookData['reservation_start_date'] = reservationStartDate;
    });

    _animationController.forward().then((_) => _animationController.reverse());

    // Lancer les confettis après la réservation
    print("Launching confetti...");  // Ajout de log de débogage
    _confettiController.play();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_bookData['title']),
        backgroundColor: Color(0xFFD2B48C),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Ajout de confettis avec positionnement et taille appropriés
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, // Direction de l'explosion
            numberOfParticles: 40, // Nombre de confettis augmenté
            shouldLoop: false, // Ne pas boucler les confettis
            gravity: 0.2, // Gravité des confettis (plus grande pour qu'ils tombent plus vite)
            emissionFrequency: 0.05, // Contrôle la fréquence des particules
            blastDirection: 3.14, // Direction vers le bas
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,  // Réduction de l'opacité pour rendre les confettis visibles
              child: Image.asset(
                'assets/wood_background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Title: ${_bookData['title']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Author: ${_bookData['author']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Description: ${_bookData['description']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ScaleTransition(
                    scale: _animationController,
                    child: ElevatedButton(
                      onPressed: _toggleReservation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD2B48C),
                        foregroundColor: Color.fromARGB(255, 250, 237, 247),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                      child: Text(
                        _bookData['disponible'] == 1
                            ? 'Reserve'
                            : 'Cancel Reservation',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: null,  // Masque la barre de navigation en bas
    );
  }
}
