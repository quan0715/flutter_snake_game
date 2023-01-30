import 'dart:math';
import 'dart:developer' as developer;

enum Direction{up, down, right, left}
class Snake{
  Direction currentDirection = Direction.right;
  List<int> snakePosition = [];
  final int boundaryCheck;
  Snake({required this.boundaryCheck}){
    int snakeInitPositionX = Random().nextInt(boundaryCheck);
    int snakeInitPositionY = Random().nextInt(boundaryCheck);
    int snakeInitPosition = snakeInitPositionX + 12 * snakeInitPositionY;
    snakePosition = [snakeInitPosition-2, snakeInitPosition-1, snakeInitPosition];
    Direction currentDirection = Direction.right;
  }
  get score => snakePosition.length - 3;
  void setDirection(Direction nextDirection){
    if(nextDirection != currentDirection){
      switch(nextDirection){
        case Direction.up:{
          if(currentDirection != Direction.down) currentDirection = nextDirection;
        }
        break;
        case Direction.down:{
          if(currentDirection != Direction.up) currentDirection = nextDirection;
        }
        break;
        case Direction.left:{
          if(currentDirection != Direction.right) currentDirection = nextDirection;
        }
        break;
        case Direction.right:{
          if(currentDirection != Direction.left) currentDirection = nextDirection;
        }
        break;
      }
      developer.log("snake move $nextDirection");
    }
  }
  bool snakeMove({required int foodPosition}){
    // snake moving method without boundary checking
    int lastPosition = snakePosition.last;
    switch(currentDirection){
      case Direction.up:{
        snakePosition.add(lastPosition >= boundaryCheck ? lastPosition - boundaryCheck : boundaryCheck * (boundaryCheck-1) + lastPosition);
      }
      break;
      case Direction.down:{
        snakePosition.add(lastPosition < boundaryCheck * (boundaryCheck-1) ? lastPosition + boundaryCheck : lastPosition % boundaryCheck);
      }
      break;
      case Direction.left:{
        snakePosition.add(lastPosition % boundaryCheck != 0 ? lastPosition - 1 : lastPosition + boundaryCheck - 1);
      }
      break;
      case Direction.right:{
        snakePosition.add(lastPosition % boundaryCheck != boundaryCheck - 1 ? lastPosition + 1 : lastPosition - boundaryCheck + 1);
      }
      break;
    }
    if (foodPosition == snakePosition.last){
      // if the head position equals to food position, food be eaten, return true
      // no need to remove the tail
      return true;
    }
    snakePosition.removeAt(0);
    return false;
  }
  bool checkAlive(){
    for(int index=0; index < snakePosition.length - 1; index++){
      // head in snake body
      if(snakePosition[index] == snakePosition.last) return false;
    }
    return true;
  }
}