
class Game implements MessageReceiver {
   Map map;
   LocalPlayer you;
   HashMap<Integer, RemotePlayer> remotePlayers = new HashMap<Integer, RemotePlayer>();
   ArrayList<String> news = new ArrayList<String>();
   
   Network network;
   
   Game() {
      map = new Map(); 
      you = new LocalPlayer();
      network = new Network(this, nick);
   }
   
   void receivedNewPlayer(int playerId, String name) {
     RemotePlayer rp = new RemotePlayer();
     remotePlayers.put(playerId, rp);
     println("Received info about new player, id=", playerId, " name=", name);
   }
   
   void receivedMovePlayer(int playerId, float x, float y, boolean crouch, boolean run, int gunId) {
     if(! remotePlayers.containsKey(playerId)) {
        println("Nonexistant playerId: ", playerId);
        return;
     }
     
     RemotePlayer remotePlayer = remotePlayers.get(playerId);
    
     remotePlayer.network_shadow_x = x;
     remotePlayer.network_shadow_y = y;
     remotePlayer.crouch = crouch;
     remotePlayer.run = run;
     
     if(remotePlayer.gun.id != gunId)
       remotePlayer.gun = new Weapon(Weapons.values()[gunId].getName());
       
     println(remotePlayer.gun.name);
   }
   
   void receivedShot(int playerId, ArrayList<Point> endsOfShots) {
     RemotePlayer remotePlayer = remotePlayers.get(playerId);
     
     /*
     for(Point pt: endsOfShots) {
       you.shooted(remotePlayer.x, remotePlayer.y, pt.x, pt.y, remotePlayer.gun);     server.. 
     }*/
     
     remotePlayer.shots = endsOfShots;
   }
   
   void receivedSetHp(int playerId, int hp, int shooterId) {
     if(playerId == -1)
       you.hp = hp;
     else {
       RemotePlayer remotePlayer = remotePlayers.get(playerId);
     
       remotePlayer.hp = hp;
     }
     
     if(hp == 0) {
        String newMessage = remotePlayers.get(shooterId).nick + " killed " + remotePlayers.get(playerId).nick + " by " + remotePlayers.get(shooterId).gun.name;
        
        if(news.size() == 4)
          news.set(3, newMessage);
        else
          news.add(newMessage);
     }
   }

   void receivedSetHp(int playerId, int hp) {
     if(playerId == -1)
       you.hp = hp;
     else {
       RemotePlayer remotePlayer = remotePlayers.get(playerId);
     
       remotePlayer.hp = hp;
     }
   }
   
   void frame() {
    network.tick();
    network.sendState(you.x, you.y, you.crouch, you.run, you.gun.id, you.shotsPoints);
     
    background(150, 200, 200); 
    
    you.setFalsePos();   
    
    map.print_map(you, remotePlayers.values());
    
    you.move(map); 
    
    printInterface();
  }
  
  void printInterface() {
    fill(255, 0, 0);
    textSize(30);
    text("hp " + you.hp + " / " + you.max_hp, 20, 30);
    text(you.gun.name + " " + you.gun.ammo + "/" + you.gun.max_ammo, 20, height-30);
    
    fill(255);
    textSize(18);
    for(int i = 0; i < news.size(); i++)
      text(news.get(i), 2*width/3, 20 * i + 20);
    
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
