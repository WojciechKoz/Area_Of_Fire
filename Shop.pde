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
  String [] indexes = {"Pistols", "SMGs", "Shotguns", "Rifles", "Heavy"};
  String [] pistols = {"pistol"};
  String [] SMGs = {"mac", "mp5", "P90"};
  String [] shotguns = {"shotgun", "super90"};
  String [] rifles = {"M14", "M4", "AK47", "rifle", "PSG-1"};
  String [] heavy = {"M61Vulcan"};
  Weapon exhibit;
  
  Shop() {
   shopState = ShopSwitch.PISTOLS;
   exhibit = new Weapon("pistol");
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
    
    
    for(int i = 0; i < 5; i++) {
      if(shopState.value() == i)
        fill(50, 50, 255);
      else
        fill(255, 0, 0);
        
      rect(0.1*width + i*buttonWi, 0.1*height, buttonWi, buttonHe);
      
      fill(0);
      text(indexes[i], 0.1*width + i*buttonWi, 0.14*height);         
    }
    fill(255, 0, 0);
    rect(0.87*width, 0.1*height, 0.03*width, buttonHe);
    
    for(int i = 0; i < 5; i++) {
      rect(0.15*width, 0.2*height + i*buttonHe*2, buttonWi, buttonHe);      
    }
    
    rect(0.15*width, 0.7*height, buttonWi, buttonHe);  // "buy" button
    
    fill(0);
    text("X", 0.875*width, 0.14*height);
    
    switch(shopState) {
      
      case PISTOLS: {
        writeWeapons(pistols);
        break;  
      }
      case SMGS: {
        writeWeapons(SMGs);
        break;
      }
      case SHOTGUNS: {
        writeWeapons(shotguns);
        break; 
      }
      case RIFLES: {
        writeWeapons(rifles);
        break; 
      }
      case HEAVY: {
        writeWeapons(heavy);
        break; 
      }
    }  
    showExhibit();
    
    text("BUY", 0.2*width , 14.7*buttonHe);
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
     if(point_in_rect(mouseX, mouseY, 0.15*width, 0.7*height, 0.14*width, 0.05*height)) {
        game.you.gun = exhibit;
        playsound("overload.wav");
     }
     switch(shopState) {
       case PISTOLS: {
         if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height, 0.14*width, 0.05*height)) {
           exhibit = new Weapon("pistol"); 
         }
         break;
       }
       case SMGS: {
         for(int i = 0; i < SMGs.length; i++) {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + i*0.1*height, 0.14*width, 0.05*height)) {
              exhibit = new Weapon(SMGs[i]); 
           }
         }
         break; 
       }
       case SHOTGUNS: {
         for(int i = 0; i < shotguns.length; i++) {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + i*0.1*height, 0.14*width, 0.05*height)) {
              exhibit = new Weapon(shotguns[i]); 
           }
         }
         break; 
       }
       case RIFLES: {
         for(int i = 0; i < rifles.length; i++) {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + i*0.1*height, 0.14*width, 0.05*height)) {
              exhibit = new Weapon(rifles[i]); 
           }
         }
         break; 
       }
       case HEAVY: {
         if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height, 0.14*width, 0.05*height)) {
            exhibit = new Weapon("M61Vulcan"); 
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
  
  private void showExhibit() { 
     text("name \t\t" + exhibit.name, width/2,height/4);
     text("damage \t\t" + exhibit.damage, width/2,height/4 + 50);
     text("accuracy \t\t" + int(exhibit.accuracy*100) + "%", width/2,height/4 + 100);
     text("fire rate \t\t" + exhibit.fire_rate + " ms", width/2,height/4 + 150);
     text("weight \t\t" + int(exhibit.weight*100) + "%", width/2,height/4 + 200);
     text("max ammo \t\t" + exhibit.max_ammo, width/2,height/4 + 250);
     text("bullets in shot \t\t" + exhibit.multiple, width/2,height/4 + 300);
     text("cost \t\t" + exhibit.cost, width/2,height/4 + 350);
  }
}
