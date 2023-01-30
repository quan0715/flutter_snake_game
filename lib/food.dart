import 'dart:math';
class Food{
  int foodPosition;
  Food({required this.foodPosition});
  factory Food.random({required int maxGridIndex}){
    int nextPosition = Random().nextInt(maxGridIndex);
    return Food(foodPosition: nextPosition);
  }
}