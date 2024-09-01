import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaborni,Fernandez,Escote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal.shade100,
      ),
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatefulWidget {
  MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String _currentBackground = 'assets/bgnamed.png';

  void exitApp(BuildContext context) {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              _currentBackground,
              fit: BoxFit.fill,
            ),
          ),
          // Main Menu Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(image: AssetImage("assets/logo.png"),),
                  SizedBox(height: 50),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Transparent background
                        foregroundColor: Colors.black,
                        minimumSize: Size(120, 50),
                        side: BorderSide(color: Colors.black, width: 2),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameScreen()),
                      );
                    },
                    child: Text(
                      "Tic Tac Toe",
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Transparent background
                        foregroundColor: Colors.black,
                        minimumSize: Size(120, 50),
                        side: BorderSide(color: Colors.black, width: 2),
                        shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CoinFlipGame()),
                      );
                    },
                    child: Text(
                      "Coin Flip",
                      style: TextStyle(fontSize: 24, color: Colors.black,),
                    ),
                  ),
                  SizedBox(height: 70),
                  Container(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 20),
                          shadowColor: Colors.black,
                          elevation: 5.0,
                        backgroundColor: Colors.cyanAccent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))
                      ),
                      onPressed: () => exitApp(context),
                      child: Text(
                        "Bye Bye!",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  GameScreen({super.key});

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  List<String> board = List.filled(9, '');
  bool isPlayerTurn = true;
  int playerWins = 0;
  int aiWins = 0;
  int draws = 0;
  bool isGameOver = false;
  String resultMessage = '';

  @override
  void initState() {
    super.initState();
    loadScores();
  }

  Future<void> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      playerWins = prefs.getInt('playerWins') ?? 0;
      aiWins = prefs.getInt('aiWins') ?? 0;
      draws = prefs.getInt('draws') ?? 0;
    });
  }

  Future<void> saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('playerWins', playerWins);
    prefs.setInt('aiWins', aiWins);
    prefs.setInt('draws', draws);
  }

  void resetBoard() {
    setState(() {
      board = List.filled(9, '');
      isPlayerTurn = true;
      isGameOver = false;
      resultMessage = '';
    });
  }

  void playerMove(int index) {
    if (board[index] == '' && !isGameOver) {
      setState(() {
        board[index] = 'O';
        isPlayerTurn = false;
      });
      checkWinner();
      if (!isGameOver) {
        aiMove();
      }
    }
  }

  void aiMove() {
    int move = findBestMove();
    if (move != -1) {
      setState(() {
        board[move] = 'X';
        isPlayerTurn = true;
      });
      checkWinner();
    }
  }

  int findBestMove() {
    // 30% chance na random para manalo naman whahahha
    if (Random().nextDouble() < 0.3) {
      List<int> availableMoves = [];
      for (int i = 0; i < board.length; i++) {
        if (board[i] == '') {
          availableMoves.add(i);
        }
      }
      return availableMoves[Random().nextInt(availableMoves.length)];
    }

    int bestScore = -999;
    int move = -1;

    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = 'X';
        int score = minimax(board, 0, false);
        board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }
    return move;
  }

  int minimax(List<String> newBoard, int depth, bool isMaximizing) {
    String winner = getWinner(newBoard);
    if (winner != '') {
      if (winner == 'X') return 10 - depth;
      if (winner == 'O') return depth - 10;
      return 0;
    }

    if (isMaximizing) {
      int bestScore = -999;
      for (int i = 0; i < newBoard.length; i++) {
        if (newBoard[i] == '') {
          newBoard[i] = 'X';
          int score = minimax(newBoard, depth + 1, false);
          newBoard[i] = '';
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 999;
      for (int i = 0; i < newBoard.length; i++) {
        if (newBoard[i] == '') {
          newBoard[i] = 'O';
          int score = minimax(newBoard, depth + 1, true);
          newBoard[i] = '';
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  String getWinner(List<String> boardToCheck) {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      String a = boardToCheck[pattern[0]];
      String b = boardToCheck[pattern[1]];
      String c = boardToCheck[pattern[2]];
      if (a == b && b == c && a != '') {
        return a;
      }
    }

    if (!boardToCheck.contains('')) {
      return 'draw';
    }

    return '';
  }

  void checkWinner() {
    String winner = getWinner(board);
    if (winner != '') {
      setState(() {
        isGameOver = true;
        if (winner == 'O') {
          resultMessage = 'You Win!';
          playerWins++;
        } else if (winner == 'X') {
          resultMessage = 'You Lose!';
          aiWins++;
        } else {
          resultMessage = "It's a Draw!";
          draws++;
        }
        saveScores();
      });
      showResultDialog();
    }
  }

  void showResultDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          resultMessage,
          textAlign: TextAlign.center,
        ),
        content: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            backgroundColor: Colors.teal,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            resetBoard();
          },
          child: Text('Play Again',
          style: TextStyle(color: Colors.black,shadows: [
            Shadow(
              blurRadius:1.0,  // shadow blur
              color: Colors.white, // shadow color
              offset: Offset(.5,.5), // how much shadow will be shown
            ),
          ],),)
        ),
      ),
    );
  }

  Widget buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(

        itemCount: board.length,
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        padding: EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => playerMove(index),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              child: Center(

                child: Text(
                  board[index],
                  style: TextStyle(
                    color: board[index] == 'O' ? Colors.blue : Colors.red,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildScoreBoard() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Player Wins: $playerWins',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 8),
          Text(
            'AI Wins: $aiWins',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 8),
          Text(
            'Draws: $draws',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        title: Text('Tic-Tac-Toe'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
          child: Image.asset(
            "assets/bg.png",
            fit: BoxFit.fill,
          ),
        ),
          Center(
            child: Column(
              children: [
                buildBoard(),
                buildScoreBoard(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Main Menu',style: TextStyle(fontSize: 15, color: Colors.black),),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// CoinFlipGame
class CoinFlipGame extends StatefulWidget {
  CoinFlipGame({super.key});

  @override
  _CoinFlipGameState createState() => _CoinFlipGameState();
}

class _CoinFlipGameState extends State<CoinFlipGame> {
  String result = '';
  String outcomes = '';
  bool _isButtonDisabled = false;
  String _imagePath = 'assets/neutral.png'; // Start with the neutral image
  String chos = '';

  void _flipCoin(String choice) {
    setState(() {
      _isButtonDisabled = true;
      _imagePath = 'assets/neutral.png'; // Show neutral image during flipping
    });

    Timer(Duration(seconds: 1), () {
      final random = Random();
      final outcome = random.nextBool() ? 'Heads' : 'Tails';

      setState(() {
        outcomes = outcome;
        result = outcome == choice ? 'You Win!' : 'You Lose!';
        _imagePath = outcome == 'Heads' ? 'assets/flip-Heads.gif' : 'assets/flip-Tails.gif';
        _isButtonDisabled = false;
        chos = choice;
      });
    });
  }

  void _resetGame() {
    setState(() {
      outcomes = '';
      result = '';
      chos = '';
      _imagePath = 'assets/neutral.png'; // Reset to neutral image
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        title: Text('Coin Flip'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/bg.png",fit: BoxFit.fill,),),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  _imagePath,
                  height: 150,
                ),
                SizedBox(height: 20),
                Text(
                  outcomes,
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius:20.0,  // shadow blur
                        color: Colors.white, // shadow color
                        offset: Offset(1.0,1.0), // how much shadow will be shown
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  result,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 40),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Your choice is: "),
                      Text("$chos", style: TextStyle(decoration: TextDecoration.underline),),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))
                        ),
                        onPressed: _isButtonDisabled ? null : () => _flipCoin('Heads'),
                        child: Text('Heads',style: TextStyle(fontSize: 15, color: Colors.lightBlueAccent,
                          shadows: [
                            Shadow(
                              blurRadius:1.0,  // shadow blur
                              color: Colors.black, // shadow color
                              offset: Offset(1.0,1.0), // how much shadow will be shown
                            ),
                          ],),),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))
                        ),
                        onPressed: _isButtonDisabled ? null : () => _flipCoin('Tails'),
                        child: Text('Tails',style: TextStyle(fontSize: 15, color: Colors.cyanAccent,
                          shadows: [
                            Shadow(
                              blurRadius:1.0,  // shadow blur
                              color: Colors.black, // shadow color
                              offset: Offset(1.0,1.0), // how much shadow will be shown
                            ),
                          ],
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))
                  ),
                  onPressed: _resetGame,
                  child: Text('Reset',style: TextStyle(color: Colors.redAccent),),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Main Menu',style: TextStyle(fontSize: 15, color: Colors.black),),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
