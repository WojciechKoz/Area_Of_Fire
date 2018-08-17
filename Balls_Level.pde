
class Level {
  int number;
  ArrayList<Enemy> enemies;
  ArrayList<ArrayList> floor_bonus;
  int counter;
  int first_shots;
  String type;
    
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
     
     first_shots = 0;
     type = "start";
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
  
  void add_bonus() {
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
      
      if(sqrt((Bplayer.x-x)*(Bplayer.x-x) + (Bplayer.y-y)*(Bplayer.y-y)) < 24) {
         if(n == "ammo")
           Bplayer.gun.give_ammo();
         else
           Bplayer.gun = new Weapon(n);
         floor_bonus.remove(i);
      }
    }
  }
  void print_interface() {   
    textSize(30);
    text("level " + number + "    elem. left " + counter + "   hp " + Bplayer.hp + "     fps" + frameRate, 20, 30);
    text(Bplayer.gun.name + " " + Bplayer.gun.ammo + "/" + Bplayer.gun.max_ammo, 20, height-30);
  }
  
  void beginning() {
    if(type == "start") {
      first_shots++;
      
      if(first_shots == 2)
        type = "game";
    } 
  }
  
  void ball_keys_down() {
    if(hasKey('a', Bplayer))
      Bplayer.keys.add('a');
    if(hasKey('d', Bplayer))
      Bplayer.keys.add('d');
    if(hasKey('w', Bplayer))
      Bplayer.keys.add('w');
    if(hasKey('s', Bplayer))
      Bplayer.keys.add('s');
    
      
    if(key == 'q' || key == 'Q')  
      Bplayer.gun = new Weapon("pistol");
    if(key == 'p' || key == 'P') {
       if(type == "pause")
         type = "game";
       else
         type = "pause";
    }
    if((key == 'm' || key == 'M') && type == "pause") {
       GP = Game_position.menu;
       menu();
    }  
    if(keyCode == SHIFT) 
      Bplayer.run = true; 
    if(key == 'c' || key == 'C')
      Bplayer.crouch = true;
    if(key == ' ')
      Bplayer.shoots = true;
  }
  // ####################################  keyUp
  
  void ball_keys_up() {
     if(key == 'A' || key == 'a') 
        for(int i = 0; i < Bplayer.keys.size(); i++)
          if((char)Bplayer.keys.get(i) == 'a')
            Bplayer.keys.remove(i);
            
    if(key == 'D' || key == 'd')
       for(int i = 0; i < Bplayer.keys.size(); i++)
          if((char)Bplayer.keys.get(i) == 'd')
            Bplayer.keys.remove(i);
            
    if(key == 'W' || key == 'w')
       for(int i = 0; i < Bplayer.keys.size(); i++)
          if((char)Bplayer.keys.get(i) == 'w')
            Bplayer.keys.remove(i);
            
    if(key == 'S' || key == 's')
       for(int i = 0; i < Bplayer.keys.size(); i++)
          if((char)Bplayer.keys.get(i) == 's')
            Bplayer.keys.remove(i);
            
    if(keyCode == SHIFT) 
      Bplayer.run = false;
    if(key == 'c' || key == 'C')
      Bplayer.crouch = false;
  
    if(key == ' ')
      Bplayer.shoots = false;  
  }
   /// ###################  FRAME
  
  void ball_frame() {
    strokeWeight(0);
    
    if(lvl.type == "game") {
      background(100, 70, 130);
      Bplayer.collision(); 
      add_bonus(); 
    }
    else
      background(150, 200, 200);    
    
    lvl.draw_lines();  
    
    bots_moves();
    Bplayer.move();
      
    lvl.print_interface();
  }
  // ####################  lvl up
  
  void ball_lvl_up() {
    Bplayer.gun = new Weapon("pistol");
    lvl = new Level(lvl.number+1);
  }
  
  // #################### game over
  
  void ball_game_over() {
    Bplayer = new BPlayer();
    lvl = new Level(1);
  }

}
