import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _startGame(bool isSinglePlayer) {
    if (isSinglePlayer) {
      _showSymbolChoiceDialog();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TicTacToeGame(isSinglePlayer: false, playerSymbol: 'X'),
        ),
      );
    }
  }

  void _showSymbolChoiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose your symbol'),
          content: const Text('Do you want to play as X or O?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TicTacToeGame(isSinglePlayer: true, playerSymbol: 'X'),
                  ),
                );
              },
              child: const Text('X'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TicTacToeGame(isSinglePlayer: true, playerSymbol: 'O'),
                  ),
                );
              },
              child: const Text('O'),
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
        title: const Text('Tic Tac Toe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _startGame(true),
              child: const Text('Single Player'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startGame(false),
              child: const Text('Two Player'),
            ),
          ],
        ),
      ),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  final bool isSinglePlayer;
  final String playerSymbol;

  const TicTacToeGame(
      {super.key, required this.isSinglePlayer, required this.playerSymbol});

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  List<String> _board = List.filled(9, '');
  late bool _isPlayerTurn;
  bool _gameOver = false;
  late String _playerSymbol;
  late String _computerSymbol;

  @override
  void initState() {
    super.initState();
    _playerSymbol = widget.playerSymbol;
    _computerSymbol = _playerSymbol == 'X' ? 'O' : 'X';
    _isPlayerTurn = _playerSymbol == 'X';
    if (widget.isSinglePlayer && !_isPlayerTurn) {
      print("Computer should make first move");
      Future.delayed(Duration(milliseconds: 500), () {
        _makeComputerMove();
      });
    }
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _isPlayerTurn = _playerSymbol == 'X';
      _gameOver = false;
    });
    if (widget.isSinglePlayer && !_isPlayerTurn) {
      print("Computer should make first move after reset");
      Future.delayed(Duration(milliseconds: 500), () {
        _makeComputerMove();
      });
    }
  }

  void _makeMove(int index) {
    if (_board[index].isNotEmpty ||
        _gameOver ||
        (!_isPlayerTurn && widget.isSinglePlayer)) {
      return;
    }

    setState(() {
      _board[index] = _isPlayerTurn ? _playerSymbol : _computerSymbol;
      _isPlayerTurn = !_isPlayerTurn;
      _checkWinner(_board[index]);
    });

    if (widget.isSinglePlayer && !_isPlayerTurn && !_gameOver) {
      print("Computer should make a move");
      Future.delayed(Duration(milliseconds: 500), () {
        _makeComputerMove();
      });
    }
  }

  void _makeComputerMove() {
    print("Making computer move");
    List<int> emptyCells = [];
    for (int i = 0; i < _board.length; i++) {
      if (_board[i].isEmpty) {
        emptyCells.add(i);
      }
    }

    if (emptyCells.isNotEmpty) {
      final random = Random();
      int randomIndex = random.nextInt(emptyCells.length);
      int moveIndex = emptyCells[randomIndex];
      print("Computer chose cell: $moveIndex");
      _makeMove(moveIndex);
    } else {
      print("No empty cells for computer move");
    }
  }

  void _checkWinner(String symbol) {
    final winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var combination in winningCombinations) {
      final a = _board[combination[0]];
      final b = _board[combination[1]];
      final c = _board[combination[2]];

      if (a.isNotEmpty && a == b && b == c && a == symbol) {
        setState(() {
          _gameOver = true;
        });
        _showWinnerDialog(symbol);
        return;
      }
    }

    if (_board.every((element) => element.isNotEmpty)) {
      setState(() {
        _gameOver = true;
      });
      _showDrawDialog();
    }
  }

  void _showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Winner!'),
          content: Text('Player $winner wins!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('New Game'),
            ),
          ],
        );
      },
    );
  }

  void _showDrawDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Draw!'),
          content: const Text('The game is a draw.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: const Text('New Game'),
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
        title: const Text('Tic Tac Toe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: 9,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () => _makeMove(index),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _board[index],
                          style: const TextStyle(
                            fontSize: 48.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _gameOver
                  ? 'Game Over'
                  : (widget.isSinglePlayer
                      ? (_isPlayerTurn ? "Your turn" : "Computer's turn")
                      : "Player ${_isPlayerTurn ? _playerSymbol : _computerSymbol}'s turn"),
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
