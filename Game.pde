
class Game implements MessageReceiver {
   Map map;
   Player you; 
   
   Network network;
   
   Game() {
      map = new Map(); 
      you = map.players.get(0); // roboczo
      network = new Network(this, nick);
   }
   
   void receivedNewPlayer(int playerId, String name) {
     println("Received info about new player, id=", playerId, " name=", name);
   }
   
   void receivedMovePlayer(int playerId, float x, float y, boolean crouch, boolean run) { 
     Player remotePlayer = map.players.get(1); // też roboczo
     
     remotePlayer.new_x = x;
     remotePlayer.new_y = y;
     remotePlayer.crouch = crouch;
     remotePlayer.run = run;
   }

   
   void frame() {
    network.tick();
    network.sendMove(you.x, you.y, you.crouch, you.run);
     
    background(150, 200, 200); 
    
    you.setFalsePos();
    
    map.print_map(you);
    
    you.move(map); 
  }
  
  void keys_down() {
    if(hasKey('a', you))
      you.keys.add('a');
    if(hasKey('d', you))
      you.keys.add('d');
    if(hasKey('w', you))
      you.keys.add('w');
    if(hasKey('s', you))
      you.keys.add('s');
    
      
    if(key == 'q' || key == 'Q')  
      you.gun = new Weapon("pistol");
  
    if(key == 'm' || key == 'M') {
       GP = Game_position.menu;
       main.show();
    }  
    if(keyCode == SHIFT) 
      you.run = true; 
    if(key == 'c' || key == 'C')
      you.crouch = true;
    if(key == ' ')
      you.shoots = true;
  }
  // ####################################  keyUp
  
  void keys_up() {
     if(key == 'A' || key == 'a') 
        for(int i = 0; i < you.keys.size(); i++)
          if((char)you.keys.get(i) == 'a')
            you.keys.remove(i);
            
    if(key == 'D' || key == 'd')
       for(int i = 0; i < you.keys.size(); i++)
          if((char)you.keys.get(i) == 'd')
            you.keys.remove(i);
            
    if(key == 'W' || key == 'w')
       for(int i = 0; i < you.keys.size(); i++)
          if((char)you.keys.get(i) == 'w')
            you.keys.remove(i);
            
    if(key == 'S' || key == 's')
       for(int i = 0; i < you.keys.size(); i++)
          if((char)you.keys.get(i) == 's')
            you.keys.remove(i);
            
    if(keyCode == SHIFT) 
      you.run = false;
    if(key == 'c' || key == 'C')
      you.crouch = false;
  
    if(key == ' ')
      you.shoots = false;  
  }
}
