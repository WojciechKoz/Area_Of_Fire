
public enum GameSwitch {
  NEW,
  MAP,
  SHOP,
  DEAD,
  STATS,
};

public enum ShopSwitch {
  PISTOLS(0),
  SMGS(1),
  SHOTGUNS(2),
  RIFLES(3),
  HEAVY(4);
  
  private int value;
  
  private ShopSwitch(int v) {
    this.value = v; 
  }
  
  public int value() {
    return this.value; 
  }
};

class Game implements MessageReceiver, TypedChatMessageReceiver {
   Map map;
   LocalPlayer you;
   HashMap<Integer, RemotePlayer> remotePlayers = new HashMap<Integer, RemotePlayer>();
   ArrayList<String> news = new ArrayList<String>();
   ChatMessage writingChatMessage;
   GameSwitch state = GameSwitch.NEW;
   ShopSwitch shopState;
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
       you.x = -3000; // visible = false ? 
       you.y = -3000;
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
        fill(100, 0, 0);
        rect(0.1*width, 0.1*height, 0.8*width, 0.8*height); // shop background
         
        // buttons
        
        stroke(0);
        strokeWeight(2);
        textSize(30);
        
        float buttonWi = 0.14*width;
        float buttonHe = 0.05*height;
        String [] names = {"Pistiols", "SMGs", "Shotguns", "Rifles", "Heavy"};
        
        for(int i = 0; i < 5; i++) {
          if(shopState.value() == i)
            fill(50, 50, 255);
          else
            fill(255, 0, 0);
            
          rect(0.1*width + i*buttonWi, 0.1*height, buttonWi, buttonHe);
          
          fill(0);
          text(names[i], 0.1*width + i*buttonWi, 0.14*height);         
        }
        fill(255, 0, 0);
        rect(0.87*width, 0.1*height, 0.03*width, buttonHe);
        
        for(int i = 0; i < 5; i++) {
          rect(0.15*width, 0.2*height + i*buttonHe*2, buttonWi, buttonHe);      
        }
        
        fill(0);
        text("X", 0.875*width, 0.14*height);
        
        switch(shopState) {
          case PISTOLS: {
            break;  
          }
          case SMGS: {
            break;
          }
          case SHOTGUNS: {
            break; 
          }
          case RIFLES: {
            break; 
          }
          case HEAVY: {
            break; 
          }
        }
              
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
          shopState = ShopSwitch.PISTOLS;
          state = GameSwitch.SHOP;         
        }
        break;
      }
      case SHOP: {
        if(key == 'b' || key == 'B') {         
          state = GameSwitch.MAP;
        }
        if(key == '1' || key == '!') {         
          shopState = ShopSwitch.PISTOLS;
        }
        if(key == '2' || key == '@') {         
          shopState = ShopSwitch.SMGS;
        }
        if(key == '3' || key == '#') {         
          shopState = ShopSwitch.SHOTGUNS;
        }
        if(key == '4' || key == '$') {         
          shopState = ShopSwitch.RIFLES;
        }
        if(key == '5' || key == '%') {         
          shopState = ShopSwitch.HEAVY;
        }
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
