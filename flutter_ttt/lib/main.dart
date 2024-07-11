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
  bool _isXTurn = true;
  bool _gameOver = false;
  bool _isEasyMode = true;

  @override
  void initState() {
    super.initState();
    if (widget.isSinglePlayer && widget.playerSymbol == 'O') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _makeComputerMove();
      });
    }
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _isXTurn = true;
      _gameOver = false;
    });

    if (widget.isSinglePlayer && widget.playerSymbol == 'O') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _makeComputerMove();
      });
    }
  }

  void _makeMove(int index) {
    if (_board[index].isNotEmpty || _gameOver) {
      return;
    }

    setState(() {
      _board[index] = _isXTurn ? 'X' : 'O';
      _isXTurn = !_isXTurn;
      _checkWinner(_board[index]);
    });

    if (widget.isSinglePlayer && !_gameOver) {
      bool isComputerTurn = (widget.playerSymbol == 'X' && !_isXTurn) ||
          (widget.playerSymbol == 'O' && _isXTurn);

      if (isComputerTurn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _makeComputerMove();
        });
      }
    }
  }

  void _makeComputerMove() {
    if (_gameOver) return;

    int moveIndex;
    if (_isEasyMode) {
      moveIndex = _makeRandomComputerMove();
    } else {
      moveIndex = _makeSophisticatedComputerMove();
    }

    if (moveIndex != -1) {
      _makeMove(moveIndex);
    }
  }

  int _makeRandomComputerMove() {
    List<int> emptySpots = [];
    for (int i = 0; i < _board.length; i++) {
      if (_board[i].isEmpty) {
        emptySpots.add(i);
      }
    }

    if (emptySpots.isNotEmpty) {
      final random = Random();
      return emptySpots[random.nextInt(emptySpots.length)];
    }
    return -1;
  }

  int _makeSophisticatedComputerMove() {
    int bestScore = -1000;
    int bestMove = -1;
    String aiPlayer = widget.playerSymbol == 'X' ? 'O' : 'X';

    for (int i = 0; i < 9; i++) {
      if (_board[i].isEmpty) {
        _board[i] = aiPlayer;
        int score = _minimax(_board, 0, false, aiPlayer);
        _board[i] = '';
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }

    return bestMove;
  }

  int _minimax(
      List<String> board, int depth, bool isMaximizing, String aiPlayer) {
    String humanPlayer = aiPlayer == 'X' ? 'O' : 'X';

    String result = _checkWinnerForMinimax(board);
    if (result != '') {
      return result == aiPlayer ? 10 - depth : depth - 10;
    }

    if (board.every((cell) => cell.isNotEmpty)) {
      return 0;
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board[i].isEmpty) {
          board[i] = aiPlayer;
          int score = _minimax(board, depth + 1, false, aiPlayer);
          board[i] = '';
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (board[i].isEmpty) {
          board[i] = humanPlayer;
          int score = _minimax(board, depth + 1, true, aiPlayer);
          board[i] = '';
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  String _checkWinnerForMinimax(List<String> board) {
    final winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var combination in winningCombinations) {
      if (board[combination[0]].isNotEmpty &&
          board[combination[0]] == board[combination[1]] &&
          board[combination[1]] == board[combination[2]]) {
        return board[combination[0]];
      }
    }

    return '';
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
        actions: [
          if (widget.isSinglePlayer)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isEasyMode = !_isEasyMode;
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: _isEasyMode ? Colors.green : Colors.red,
                ),
                child: Text(_isEasyMode ? 'Easy' : 'Hard'),
              ),
            ),
        ],
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
                  : ("Player ${_isXTurn ? 'X' : 'O'}'s turn"),
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
