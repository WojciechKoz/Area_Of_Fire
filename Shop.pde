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

class Shop {
  float buttonWi, buttonHe;
  ShopSwitch shopState;
  
  Shop() {
   shopState = ShopSwitch.PISTOLS;
  }
  
  void print() {
    fill(100, 0, 0);
    rect(0.1*width, 0.1*height, 0.8*width, 0.8*height); // shop background
     
    // buttons
    
    stroke(0);
    strokeWeight(2);
    textSize(30);
    
    float buttonWi = 0.14*width;
    float buttonHe = 0.05*height;
    String [] names = {"Pistols", "SMGs", "Shotguns", "Rifles", "Heavy"};
    
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
        String[] args = {"pistol"};
        writeWeapons(args);
        break;  
      }
      case SMGS: {
        String[] args = {"mac", "mp5", "P90"};
        writeWeapons(args);
        break;
      }
      case SHOTGUNS: {
        String[] args = {"shotgun", "super90"};
        writeWeapons(args);
        break; 
      }
      case RIFLES: {
        String[] args = {"M14", "M4", "AK47", "rifle", "PSG-1"};
        writeWeapons(args);
        break; 
      }
      case HEAVY: {
        String[] args = {"M61Vulcan"};
        writeWeapons(args);
        break; 
      }
    }
  }
  
  void click() {
     for(int i = 0; i < 5; i++) {
       if(point_in_rect(mouseX, mouseY, 0.1*width + i*0.14*width, 0.1*height, 0.14*width, 0.05*height)) {
          shopState = ShopSwitch.values()[i]; 
       }
     }
     if(point_in_rect(mouseX, mouseY, 0.87*width, 0.1*height, 0.03*width, 0.05*height)) {
          game.state = GameSwitch.MAP; 
     }
     switch(shopState) {
       case PISTOLS: {
         if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height, 0.14*width, 0.05*height)) {
           game.you.gun = new Weapon("pistol"); 
         }
         break;
       }
       case SMGS: {
         String[] names = {"mac", "mp5", "P90"};
         for(int i = 0; i < names.length; i++) {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + i*0.1*height, 0.14*width, 0.05*height)) {
              game.you.gun = new Weapon(names[i]); 
           }
         }
         break; 
       }
       case SHOTGUNS: {
         if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height, 0.14*width, 0.05*height)) {
            game.you.gun = new Weapon("shotgun"); 
         }
         if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + 0.1*height, 0.14*width, 0.05*height)) {
            game.you.gun = new Weapon("super90"); 
         }
         break; 
       }
       case RIFLES: {
         String[] names = {"M14", "M4", "AK47", "rifle", "PSG-1"};
         for(int i = 0; i < names.length; i++) {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + i*0.1*height, 0.14*width, 0.05*height)) {
              game.you.gun = new Weapon(names[i]); 
           }
         }
         break; 
       }
       case HEAVY: {
         if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height, 0.14*width, 0.05*height)) {
            game.you.gun = new Weapon("M61Vulcan"); 
         }
         break; 
       }           
     } 
  }
  
  void key_down() {
    if(key == 'b' || key == 'B') {         
      game.state = GameSwitch.MAP;
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
  
  private void writeWeapons(String[] args) {
    for(int i = 0; i < args.length; i++) {
       text(args[i], 0.15*width, 0.24*height + i*0.1*height);      
    }
  }
}
