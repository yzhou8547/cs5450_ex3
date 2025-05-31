import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const BallCollectGameApp());
}

class BallCollectGameApp extends StatelessWidget {
  const BallCollectGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  double bucketPosition = 0;
  List<Ball> balls = [];
  int score = 0;
  final random = Random();
  late AnimationController _controller;
  final double bucketWidth = 80;
  final double bucketHeight = 60;
  final double ballRadius = 15;
  final double gravity = 2.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateGame);
    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (balls.isEmpty) {
      _spawnBall();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateGame() {
    if (!mounted) return;
    
    setState(() {
      // Update ball positions with gravity
      for (var ball in balls) {
        ball.y += gravity;
      }

      // Remove balls that fall below screen
      balls.removeWhere((ball) => ball.y > MediaQuery.of(context).size.height);

      // Check for collisions with bucket
      final screenHeight = MediaQuery.of(context).size.height;
      for (int i = balls.length - 1; i >= 0; i--) {
        final ball = balls[i];
        if (ball.y + ballRadius >= screenHeight - bucketHeight &&
            ball.x >= bucketPosition - bucketWidth/2 &&
            ball.x <= bucketPosition + bucketWidth/2) {
          balls.removeAt(i);
          score++;
          _spawnBall();
        }
      }

      // Spawn new balls occasionally
      if (random.nextDouble() < 0.02) {
        _spawnBall();
      }
    });
  }

  void _spawnBall() {
    final size = MediaQuery.of(context).size;
    balls.add(Ball(
      x: random.nextDouble() * size.width,
      y: 0,
    ));
  }

  void _handleDrag(DragUpdateDetails details) {
    setState(() {
      final newPosition = bucketPosition + details.delta.dx;
      final screenWidth = MediaQuery.of(context).size.width;
      // Keep bucket within screen bounds
      bucketPosition = newPosition.clamp(bucketWidth/2, screenWidth - bucketWidth/2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return GestureDetector(
      onPanUpdate: _handleDrag,
      child: Stack(
        children: [
          // Balls
          ...balls.map((ball) => Positioned(
            left: ball.x - ballRadius,
            top: ball.y - ballRadius,
            child: Container(
              width: ballRadius * 2,
              height: ballRadius * 2,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          )),
          // Bucket
          Positioned(
            left: bucketPosition - bucketWidth/2,
            top: size.height - bucketHeight,
            child: Container(
              width: bucketWidth,
              height: bucketHeight,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Score
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              'Score: $score',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Ball {
  double x;
  double y;
  
  Ball({required this.x, required this.y});
}
