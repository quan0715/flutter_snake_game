import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'snake.dart';
import 'food.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const SnakeGamePage(),
    );
  }
}

class SnakeGamePage extends StatefulWidget {
  const SnakeGamePage({super.key});
  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}
enum Status{restart, start, stop, end}
class _SnakeGamePageState extends State<SnakeGamePage> {
  final int numberOfGrid = 144;
  final int numberOfRow = 12;
  int bestScore = 0;
  Status gameStatus = Status.restart;
  Snake snake = Snake(boundaryCheck: 12);
  Food food = Food.random(maxGridIndex: 144);
  Timer clock = Timer(const Duration(milliseconds: 150), () { });
  void startGame() {
    gameStatus = Status.start;
    clock = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        bool eatenFood = snake.snakeMove(foodPosition: food.foodPosition);
        if (eatenFood){
          food = Food.random(maxGridIndex: 144);
        }
        bool snakeAlive = snake.checkAlive();
        if (!snakeAlive){
          gameStatus = Status.end;
          clock.cancel();
          showDialog(context: context, builder: (context){
            return const AlertDialog(
              title: Text('Game Over'),
            );
          });
        }
        bestScore = max(bestScore, snake.score);
      });
    });
  }
  void stopGame(){
    developer.log('stop the game');
    setState(() {
      gameStatus = Status.stop;
      clock.cancel();
    });
  }
  void gameInit(){
    setState(() {
      snake = Snake(boundaryCheck: 12);
      food = Food.random(maxGridIndex: 144);
      gameStatus = Status.restart;
    });
  }

  Widget setButton(){
    switch(gameStatus){
      case Status.restart:{
        return ControlButton(text: "Start",color: Colors.amberAccent, handler: startGame);
      }
      case Status.start:{
        return ControlButton(text: "Stop",color: Colors.blueAccent, handler: stopGame);
      }
      case Status.stop:{
        return ControlButton(text: "Continue",color: Colors.greenAccent, handler: startGame);
      }
      case Status.end:{
        return ControlButton(text: "New Game",color: Colors.redAccent, handler: gameInit);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            children: [
              Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    margin: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RecordDisplayLabel(
                          label: "Score",
                          value: snake.score.toString(),
                        ),
                        RecordDisplayLabel(
                          label: "Best Score",
                          value: bestScore.toString(),
                        ),
                      ],
                    ))
              ),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if(gameStatus == Status.start) {
                      if (details.delta.dy < 0) {
                        snake.setDirection(Direction.up);
                      } else {
                        snake.setDirection(Direction.down);
                      }
                    }
                  },
                  onHorizontalDragUpdate: (details){
                    if(gameStatus == Status.start) {
                      if (details.delta.dx < 0) {
                        snake.setDirection(Direction.left);
                      } else {
                        snake.setDirection(Direction.right);
                      }
                    }
                  },
                  child: GridView.builder(
                      itemCount: numberOfGrid,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: numberOfRow
                      ),
                      itemBuilder: (context, index) {
                        if (snake.snakePosition.contains(index)) {
                          if (index == snake.snakePosition.last){
                            return const GameUnit(bodyColor: Colors.amber);
                          }
                          return const GameUnit(bodyColor: Colors.amberAccent);
                        } else if (index == food.foodPosition) {
                          return const GameUnit(bodyColor: Colors.greenAccent);
                        } else {
                          return const GameUnit();
                        }
                      }
                  ),
                ),
              ),
              Expanded(
                  child: Center(
                child: setButton()
              ))
            ],
          ),
        ));
  }
}

class GameUnit extends StatefulWidget {
  // int? index;
  final Color? bodyColor;
  const GameUnit({super.key, this.bodyColor = Colors.grey});

  @override
  State<GameUnit> createState() => _GameUnitState();
}

class _GameUnitState extends State<GameUnit> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        decoration: BoxDecoration(
            color: widget.bodyColor,
            borderRadius: const BorderRadius.all(Radius.circular(6.0))),
      ),
    );
  }
}

class RecordDisplayLabel extends StatelessWidget {
  final String label;
  final String value;

  const RecordDisplayLabel({
    super.key,
    required this.label,
    required this.value
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        //color: Colors.amberAccent,
          border: Border.all(
              color: Colors.white
          )
        // borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(3.0),
            decoration: const BoxDecoration(
              //color: Colors.white,
              //borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade200,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Text(value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ControlButton extends StatelessWidget{
  const ControlButton({
    super.key,
    this.textColor = Colors.white,
    required this.text,
    required this.color,
    required this.handler,
  });
  final Color color;
  final String text;
  final handler;
  final Color textColor;
  @override
  Widget build(BuildContext context){
    return MaterialButton(
      color: color,
      onPressed: handler,
      textColor: textColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Text(text)
    );
  }
}