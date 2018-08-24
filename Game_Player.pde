abstract class Player {
  final float radius = 13;
  final int max_hp = 5;
  final float mobility = 250;
  
  String nick;
  float x, y;
  Weapon gun;
  boolean shoots;
  boolean run;
  boolean crouch;
  int hp;
  Teams team;
  
  Point relative = new Point(0,0);
  
  Player() {
    x = -2000;
    y = -2000;
    
    gun = new Weapon("M4");
    hp = max_hp;
    run = false;
    crouch = false;
    nick = "";
    team = Teams.NEUTRAL;
  }
}

enum Teams {
  BLUE,
  RED,
  NEUTRAL,
};
