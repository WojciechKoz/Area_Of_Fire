
public enum GameSwitch {
  NEW,
  MAP,
  SHOP,
  DEAD,
  STATS,
};

class Game implements MessageReceiver, TypedChatMessageReceiver {
   Map map;
   LocalPlayer you;
   HashMap<Integer, RemotePlayer> remotePlayers = new HashMap<Integer, RemotePlayer>();
   ArrayList<String> news = new ArrayList<String>();
   ChatMessage writingChatMessage;
   GameSwitch state = GameSwitch.NEW;
   Shop shop;
   int bluePoints = 0, redPoints = 0;
   
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
       state = GameSwitch.DEAD;
     }  
     
     if(hp <= 0) {  
       newMessage(shooter.nick + " killed " + shot.nick + " by " + shooter.gun.name);
       shooter.kills++; // server czy klient ?
       shot.deaths++;
     }
   }
   
   void receivedChatMessage(String msg) {
     newMessage(msg);
   }
   
   void playerTypedChatMessage(String msg) {
     network.sendChatMessage(msg);
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
   
   void receivedColor(int playerId, int teamColor) {
     Player rp = remotePlayers.get(playerId);
     if(rp != null) {
        rp.team = Teams.values()[teamColor];
     } 
   }
   
   void frame() {
    network.tick();
    if(state == GameSwitch.MAP)
      network.sendState(you.x, you.y, you.crouch, you.run, you.gun.id, you.shotsPoints);
     
    background(150, 200, 200); 
    
    you.setFalsePos();   
    
    map.print_map(you, remotePlayers.values());
    
    you.move(map); 
    
    printInterface();
  }



  void printInterface() {

    
    noStroke();
    switch(state) {
      case NEW: {

        background(100, 200, 200);
        fill(0);
        text("TDM map \"sandbox\"", width/2 - 125, height/2 - 40);
        
        fill(0, 0, 255);
        rect(100, height/2, width/2 - 100, 250); 
        fill(0);
        text("Play As Blue " + bluePoints, 120 , height/2 + 125);
        
        fill(255, 0, 0);
        rect(width/2, height/2, width/2 - 100, 250); 
        fill(0);
        text("Play As Red " + redPoints, width/2 + 20, height/2 + 125); 
        break;
      }
      case MAP: {
        mapInterface();       
        break;
      }
      case SHOP: {
        shop.print();
              
        mapInterface();
        
        break;
      }
      case DEAD: {
        background(100, 200, 200);
        
        fill(0);
        text("You have been killed", width/2 - 140, height/3 - 20);
        
        fill(255, 0, 0);
        rect(width/3, height/3, width/3, height/3); 
        fill(0);
        text("Respawn", width/2 - 60, height/2); 
        
        break;
      }
    }
  }
  
  void mouseUp() {
    if(state == GameSwitch.MAP)
         game.you.shoots = false;
  }
  
  void mouseDown() {
    switch(state) {
       case NEW: {
        if(point_in_rect(mouseX, mouseY, 100, height/2, width/2 - 100, 250)) {
          you.team = Teams.BLUE; 
          you.onRespawn(map);
          state = GameSwitch.MAP;
          network.sendTeamColor(0);
          network.sendRespawn();
        }
        if(point_in_rect(mouseX, mouseY, width/2, height/2, width/2 - 100, 250)) {
          you.team = Teams.RED; 
          you.onRespawn(map); 
          state = GameSwitch.MAP;
          network.sendTeamColor(1);
          network.sendRespawn();
        }
        break;
      }
       case MAP:
         game.you.shoots = true; break;
       case DEAD: {
         if(point_in_rect(mouseX, mouseY, width/3, height/3, width/3, height/3)) {
          you.onRespawn(map);
          state = GameSwitch.MAP;
          network.sendRespawn();
         }
         break;
       }
       case SHOP: {
         shop.click();     
         break;
       }
         
    }
     
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
    if(state == GameSwitch.MAP || state == GameSwitch.DEAD) {
      if(writingChatMessage != null) {
        if(key == BACKSPACE) {
          writingChatMessage.backspace();
        } else if(key == ENTER || key == RETURN) {
          writingChatMessage.finalise();
          writingChatMessage = null;
        }
        return;
      }
    }

    switch(state) {
      case MAP: {
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
        if(key == 'b' || key == 'B') {
          shop = new Shop();
          state = GameSwitch.SHOP;         
        }
        break;
      }
      case SHOP: {
        shop.key_down();
        break;
      }
    }
  }
  // ####################################  keyUp
  
  void keys_up() {
    switch(state) {
      case MAP: {
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
        
      break;      
      }
    }
  }
  
  private void mapInterface() {
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
  

}
