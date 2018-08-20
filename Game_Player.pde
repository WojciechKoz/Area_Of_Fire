abstract class Player {
  final float radius = 13;
  final int max_hp = 5;
  final float mobility = 250;
  
  float x, y;;
  Weapon gun;
  boolean shoots;
  boolean run;
  boolean crouch;
  int hp;
  
  Point relative = new Point(0,0);
  
  Player() {
    x = 300;
    y = 330;
    
    gun = new Weapon("pistol");
    hp = max_hp;
    run = false;
    crouch = false;
  }
  
  

  
}
