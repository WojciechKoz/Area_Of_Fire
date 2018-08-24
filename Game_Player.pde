abstract class Player {
  final float radius = 13;
  int max_hp = 5;
  final float mobility = 250;
  
  String nick;
  float x, y;
  Weapon gun;
  boolean shoots;
  boolean run;
  boolean crouch;
  int hp;
  Teams team;
  int kills, deaths;
  
  Point relative = new Point(0,0);
  
  Player() {
    x = -3000;
    y = -3000;
    
    gun = new Weapon("M4");
    hp = max_hp;
    run = false;
    crouch = false;
    nick = "";
    
    team = Teams.NEUTRAL;
    
    kills = 0;
    deaths = 0;
  }
}

public enum Teams {
  BLUE(0),
  RED(1),
  NEUTRAL(2);
  
  private int value;
  
  private Teams(int v) {
    this.value = v;
  }
  
  public int value() {
    return this.value; 
  }
};
