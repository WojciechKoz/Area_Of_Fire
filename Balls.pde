enum Type {start, pause, game};

class Balls {
  Level lvl;
  BPlayer player;
  Type type;
  int first_shots;
  
  Balls() {
     lvl = new Level(1);
     
     player = new BPlayer();
     
     first_shots = 0;
     type = Type.start;
  }
  
  void keys_down() {
    if(hasKey('a', player))
      player.keys.add('a');
    if(hasKey('d', player))
      player.keys.add('d');
    if(hasKey('w', player))
      player.keys.add('w');
    if(hasKey('s', player))
      player.keys.add('s');
    
      
    if(key == 'q' || key == 'Q')  
      player.gun = new Weapon("pistol");
    if(key == 'p' || key == 'P') {
       if(type == Type.pause)
         type = Type.game;
       else
         type = Type.pause;
    }
    if((key == 'm' || key == 'M') && type == Type.pause) {
       GP = Game_position.menu;
       main.show();
    }  
    if(keyCode == SHIFT) 
      player.run = true; 
    if(key == 'c' || key == 'C')
      player.crouch = true;
    if(key == ' ')
      player.shoots = true;
  }
  // ####################################  keyUp
  
  void keys_up() {
     if(key == 'A' || key == 'a') 
        for(int i = 0; i < player.keys.size(); i++)
          if((char)player.keys.get(i) == 'a')
            player.keys.remove(i);
            
    if(key == 'D' || key == 'd')
       for(int i = 0; i < player.keys.size(); i++)
          if((char)player.keys.get(i) == 'd')
            player.keys.remove(i);
            
    if(key == 'W' || key == 'w')
       for(int i = 0; i < player.keys.size(); i++)
          if((char)player.keys.get(i) == 'w')
            player.keys.remove(i);
            
    if(key == 'S' || key == 's')
       for(int i = 0; i < player.keys.size(); i++)
          if((char)player.keys.get(i) == 's')
            player.keys.remove(i);
            
    if(keyCode == SHIFT) 
      player.run = false;
    if(key == 'c' || key == 'C')
      player.crouch = false;
  
    if(key == ' ')
      player.shoots = false;  
  }
   /// ###################  FRAME
  
  void frame() {
    strokeWeight(0);
    
    if(type == Type.game) {
      background(100, 70, 130);
      ((BPlayer)player).collision(lvl); 
      lvl.add_bonus(player); 
    }
    else
      background(150, 200, 200);    
    
    lvl.draw_lines();  
    
    bots_moves();
    ((BPlayer)player).move(lvl);
      
    lvl.print_interface(player);
  }
  // ####################  lvl up
  
  void lvl_up() {
    if(lvl.number == 9) {
      main.show();
      GP = Game_position.menu;
    }
    player.gun = new Weapon("pistol");
    lvl = new Level(lvl.number+1);
    
    type = Type.start;
    first_shots = 0;
  }
  
  // #################### game over
  
  void game_over() {
    player = new BPlayer();
    lvl = new Level(1);
    
    type = Type.start;
    first_shots = 0;
  }
  
  void bots_moves() {
    for(Enemy b: lvl.enemies) {
      if(b.visible) {
        if(type != Type.pause)
          b.move();          
        b.print_it(lvl);
      }
    }
  }
  
  void beginning() {
    if(type == Type.start) {
      first_shots++;
      
      if(first_shots == 2)
        type = Type.game;
    } 
  }
}
