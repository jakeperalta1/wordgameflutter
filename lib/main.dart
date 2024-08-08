import 'package:flutter/material.dart';

void main() => runApp(HangmanApp());

class HangmanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,  // Removes the debug tag
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HangmanGame(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/word.jpg'),
              fit: BoxFit.cover,  // Ensures the image fits the screen
            ),
          ),
        ),
      ),
    );
  }
}

class HangmanGame extends StatefulWidget {
  @override
  _HangmanGameState createState() => _HangmanGameState();
}

class _HangmanGameState extends State<HangmanGame> {
  final List<Map<String, String>> wordList = [
    {'word': 'movie', 'hint': 'moving picture'},
    {'word': 'crown', 'hint': 'ornament worn on head'},
    {'word': 'magnet', 'hint': 'has northpole and southpole'},
    {'word': 'bibliophile', 'hint': 'a person who loves to read books'},
    {'word': 'Beatles', 'hint': 'one of the most famous musical bands from the 70s'},
  ];

  String currentWord = '';
  String currentHint = '';
  Set<String> guessedLetters = {};
  int wrongGuesses = 0;
  bool gameOver = false;
  bool playerWon = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      final wordData = wordList[(wordList.length * (DateTime.now().millisecondsSinceEpoch % 1000) ~/ 1000) % wordList.length];
      currentWord = wordData['word']!.toUpperCase();
      currentHint = wordData['hint']!;
      guessedLetters.clear();
      wrongGuesses = 0;
      gameOver = false;
      playerWon = false;
    });
  }

  void _guessLetter(String letter) {
    if (!gameOver && !guessedLetters.contains(letter)) {
      setState(() {
        guessedLetters.add(letter);
        if (!currentWord.contains(letter)) {
          wrongGuesses++;
          if (wrongGuesses == 6) {
            gameOver = true;
            playerWon = false;
          }
        } else if (_wordIsFullyGuessed()) {
          gameOver = true;
          playerWon = true;
        }
      });
    }
  }

  bool _wordIsFullyGuessed() {
    return currentWord.split('').every((letter) => guessedLetters.contains(letter));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guess the Word!'),
        backgroundColor: const Color.fromARGB(255, 132, 184, 207),  // Changed app bar color to light blue
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/photo2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildHintDisplay(),
                SizedBox(height: 20),
                _buildWordDisplay(),
                SizedBox(height: 20),
                _buildWrongGuessesDisplay(),
                SizedBox(height: 20),
                _buildGuessedLettersDisplay(),
                SizedBox(height: 20),
                _buildKeyboard(),
                if (gameOver) ...[
                  Spacer(),  // Moves the Play Again button and game over message to the bottom
                  _buildGameOverDisplay(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintDisplay() {
    return Container(
      padding: EdgeInsets.all(10),
      color: const Color.fromARGB(255, 159, 99, 79),  // Light brown color
      child: Text(
        'Hint: $currentHint',
        style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildWordDisplay() {
    return Text(
      currentWord.split('').map((letter) => guessedLetters.contains(letter) ? letter : '_').join(' '),
      style: TextStyle(fontSize: 32, letterSpacing: 8),  // Larger letters and more spacing
    );
  }

  Widget _buildWrongGuessesDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(6 - wrongGuesses, (index) => Icon(Icons.favorite, color: Colors.red, size: 30)),
      ],
    );
  }

  Widget _buildGuessedLettersDisplay() {
    return Column(
      children: <Widget>[
        Text(
          'Guesses:',
          style: TextStyle(fontSize: 16),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: guessedLetters.map((letter) {
            return Text(
              letter,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),  // Slightly smaller text
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGameOverDisplay() {
    return Column(
      children: <Widget>[
        Text(
          playerWon ? 'You WON!' : 'You LOST!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: playerWon ? Colors.green : Colors.red),
        ),
        SizedBox(height: 10),
        Container(
          color: Colors.white,  // White background for the icon container
          child: IconButton(
            onPressed: _startNewGame,
            icon: Icon(Icons.refresh, size: 30, color: Colors.green),  // Icon for "Play Again"
          ),
        ),
      ],
    );
  }

  Widget _buildKeyboard() {
    return Wrap(
      spacing: 8.0,  // Increased spacing between buttons
      runSpacing: 6.0,  // Increased vertical spacing between rows
      children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').map((letter) {
        return Container(
          padding: EdgeInsets.all(4),
          child: ElevatedButton(
            onPressed: () => _guessLetter(letter),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,  // Button color
            ),
            child: Text(
              letter,
              style: TextStyle(color: Colors.black, fontSize: 24),  // Larger text
            ),
          ),
        );
      }).toList(),
    );
  }
}
