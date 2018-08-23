
class Game implements MessageReceiver, TypedChatMessageReceiver {
   Map map;
   LocalPlayer you;
   HashMap<Integer, RemotePlayer> remotePlayers = new HashMap<Integer, RemotePlayer>();
   ArrayList<String> news = new ArrayList<String>();
   ChatMessage writingChatMessage;
   
   Network network;
   
   Game() {
      map = new Map(); 
      you = new LocalPlayer();
      network = new Network(this, you.nick);
   }
   
   public void close() {
      network.close(); 
   }
   
   private Player getPlayerById(int id) {
     if(id == -1)
       return you;
     return remotePlayers.get(id);
   }
   
   private void newMessage(String message) {
     if(news.size() >= 6)
       news.remove(0);
     
     news.add(message);
   }
   
   void receivedNewPlayer(int playerId, String name) {
     RemotePlayer rp = new RemotePlayer();
     remotePlayers.put(playerId, rp);
     println("Received info about new player, id=", playerId, " name=", name);
     
     rp.nick = name;
     
     newMessage(rp.nick + " joined the game!");
   }
   
   void receivedMovePlayer(int playerId, float x, float y, boolean crouch, boolean run, int gunId) {
     RemotePlayer remotePlayer = remotePlayers.get(playerId);
     
     if(remotePlayer == null) {
        println("Nonexistant playerId: ", playerId);
        return; 
     }
    
     remotePlayer.network_shadow_x = x;
     remotePlayer.network_shadow_y = y;
     remotePlayer.crouch = crouch;
     remotePlayer.run = run;
     
     remotePlayer.receivedMove();

     if(remotePlayer.gun.id != gunId)
       remotePlayer.gun = new Weapon(Weapons.values()[gunId].getName());
   }
   
   void receivedShot(int playerId, ArrayList<Point> endsOfShots) {
     RemotePlayer remotePlayer = remotePlayers.get(playerId);
     
     if(remotePlayer == null) {
        println("Received SHOT with wrong player id: ", playerId);
        return;
     }
     
     /*
     for(Point pt: endsOfShots) {
       you.shooted(remotePlayer.x, remotePlayer.y, pt.x, pt.y, remotePlayer.gun);     server.. 
     }*/
     
     remotePlayer.shots = endsOfShots;
   }
   
   void receivedSetHp(int playerId, int hp, int shooterId) {
     Player shooter = getPlayerById(shooterId);
     Player shot = getPlayerById(playerId);
     
     if(shooter == null || shot == null) {
       println("Received SET_HP(3) with nonexistant player id");
       return;
     }
     
     shot.hp = hp;
     
     if(you.hp <= 0) {
       GP = Game_position.menu;
       close();
       return;
      //you = new LocalPlayer();
     }  
     
     if(hp <= 0) {  
       newMessage(shooter.nick + " killed " + shot.nick + " by " + shooter.gun.name);
     }
   }

   void receivedSetHp(int playerId, int hp) {
     Player player = getPlayerById(playerId);
     if(player == null) {
       println("Received SET_HP(2) with nonexistant player id: ", playerId);
       return;
     }
     player.hp = hp;
   }
   
   void receivedDisconnect(int playerId) { 
     if(remotePlayers.get(playerId) != null ) {
        newMessage(remotePlayers.get(playerId).nick + " left the game!");      
        remotePlayers.remove(playerId);
     }
   }
   
   void receivedChatMessage(String msg) {
     newMessage(msg);
   }
   
   void playerTypedChatMessage(String msg) {
     network.sendChatMessage(msg);
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
    if(writingChatMessage != null)
      text(writingChatMessage.getTypingMessage(), 2*width/3, 20 * news.size() + 20);  
    
    text("FPS " + int(frameRate), width - 70, height - 20);
    
  }
  
  void keys_typed(KeyEvent ev) {
    if(writingChatMessage == null) {
      if(ev.getKey() == 't') {
        writingChatMessage = new ChatMessage(this);
      }
      
      return;
    }
    
    writingChatMessage.keys_typed(ev);
  }
  
  void keys_down() {
    if(writingChatMessage != null) {
      if(key == BACKSPACE) {
        writingChatMessage.backspace();
      } else if(key == ENTER || key == RETURN) {
        writingChatMessage.finalise();
        writingChatMessage = null;
      }
      return;
    }

      
    if(hasKey('a', you))
      you.keys.add('a');
    if(hasKey('d', you))
      you.keys.add('d');
    if(hasKey('w', you))
      you.keys.add('w');
    if(hasKey('s', you))
      you.keys.add('s');
    
      
    if(key == 'q' || key == 'Q')  
      you.gun = new Weapon("M4");
  
    if(key == 'm' || key == 'M') {
       GP = Game_position.menu;
       close();
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
