
class Level {
  int number;
  ArrayList<Enemy> enemies;
  ArrayList<ArrayList> floor_bonus;
  int counter;

  Level(int num) {
     
     number = num;
     
     enemies = new ArrayList<Enemy>();
     
     floor_bonus = new ArrayList<ArrayList>();
     
     int [] numberOfBalls = {7, 12, 15, 17, 0, 3, 0};
     int [] numberOfCrazies = {0, 0, 2, 4, 0, 17, 30};
     
     for(int i = 0; i < numberOfBalls[num-1]; i++) {
        enemies.add(new Ball()); 
     }
     for(int i = 0; i < numberOfCrazies[num-1]; i++) {
        enemies.add(new Crazy()); 
     }
     if(num == 5) {
       for(int i = 0; i < 15; i++) {
         enemies.add(new DivBoss(100, 200, 250, 250, i));
         enemies.get(i).visible = false;
       }  
       enemies.get(0).visible = true;
     }
     counter = enemies.size();
  }
  
  void new_thing(String n) {
    floor_bonus.add(new ArrayList());
    floor_bonus.get(floor_bonus.size()-1).add(n);
    floor_bonus.get(floor_bonus.size()-1).add(int(random(160, width-160)));
    floor_bonus.get(floor_bonus.size()-1).add(int(random(160, height-160))); 
  }
  
  void draw_lines() {
    strokeWeight(6);
    stroke(255, 100, 100);
    
    line(150, 150, width-150, 150);
    line(width-150, 150, width-150, height-150);
    line(width-150, height-150, 150, height - 150);
    line(150, height - 150, 150, 150);
    
    strokeWeight(0);
  }
  
  void add_bonus(Player player) {
    float r = random(0, 1);
    
    if(r > (1 - (0.005 * 1/frameRate))) 
      new_thing("M61Vulcan");
    else if(r > (1 - (0.01 * 1/frameRate)))
      new_thing("PSG-1");
    else if(r > (1 - (0.02 * 1/frameRate)))
      new_thing("rifle");
    else if(r > (1 - (0.04 * 1/frameRate))) 
      new_thing("AK47");
    else if(r > (1 - (0.06 * 1/frameRate)))
      new_thing("M4");
    else if(r > (1 - (0.08 * 1/frameRate)))
      new_thing("M14");
    else if(r > (1 - (0.1 * 1/frameRate)))
      new_thing("mac");
    else if(r > (1 - (0.14 * 1/frameRate)))
      new_thing("shotgun");
    else if(r > (1 - (0.18 * 1/frameRate)))
      new_thing("super90");
    else if(r > (1 - (0.22 * 1/frameRate)))
      new_thing("P90");
    else if(r > (1 - (0.26 * 1/frameRate)))
      new_thing("mp5");
    else if(r > (1 - (0.30 * 1/frameRate)))
      new_thing("ammo");
    
    for(int i = 0; i < floor_bonus.size(); i++) {
      int x = (int)floor_bonus.get(i).get(1);
      int y = (int)floor_bonus.get(i).get(2);
      String n = (String)floor_bonus.get(i).get(0);
      
      if(n == "ammo")
        fill(255,255,255);
      else
        fill(0,0,0);
      rect(x, y, 12.0, 12.0);
      textSize(10);
      
      if(n == "ammo") {
        fill(0,0,0);
        text("A", x + 3, y + 10);
      }
      else {
        fill(255,255,255);
        text("W", x + 3, y + 10);
      }
      
      if(sqrt((player.x-x)*(player.x-x) + (player.y-y)*(player.y-y)) < 24) {
         if(n == "ammo")
           player.gun.give_ammo();
         else
           player.gun = new Weapon(n);
         floor_bonus.remove(i);
      }
    }
  }
  void print_interface(Player player) {   
    textSize(30);
    text("level " + number + "    elem. left " + counter + "   hp " + player.hp + "     fps" + frameRate, 20, 30);
    text(player.gun.name + " " + player.gun.ammo + "/" + player.gun.max_ammo, 20, height-30);
  }
  

  


}
