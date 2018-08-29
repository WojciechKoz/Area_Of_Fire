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
  boolean [] hovered = {false, false, false, false, false};
  Weapon exhibit;
  
  Shop() {
   shopState = ShopSwitch.PISTOLS;
   exhibit = new Weapon("pistol");
  }
  
  private float buttonHeight() {
     return height*0.05; 
  }
  
  private float buttonWidth() {
     return width*0.14; 
  }
  
  void print() {
    fill(color(0x62, 0x46, 0x40, 213));
    rect(0.1*width, 0.1*height, 0.8*width, 0.8*height, 20); // shop background
    
    stroke(0);
    strokeWeight(2);
    textSize(30);
    
    textAlign(CENTER, CENTER);
    
    for(int i = 0; i < 5; i++) {
      int _color = shopState.value() == i ? 140 : 230;    
      printButton(indexes[i], 0.1*width + i*buttonWidth(), 0.1*height, _color);
    }
    
    printExit();

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
    textAlign(LEFT, CENTER);
  }
  
  void click() {
     for(int i = 0; i < 5; i++) { // change of weapons type 
       if(point_in_rect(mouseX, mouseY, 0.1*width + i*0.14*width, 0.1*height, buttonWidth(), buttonHeight())) {
          shopState = ShopSwitch.values()[i]; 
       }
     }
     
     if(point_in_rect(mouseX, mouseY, 0.87*width, 0.1*height, 0.03*width, buttonHeight())) { // exit
        game.state = GameSwitch.MAP; 
     }
     
     switch(shopState) { // buying
       case PISTOLS: {
         if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height, buttonWidth(), buttonHeight())) {
           game.you.gun = exhibit;
           playsound("overload.wav");
         }
         
         break;
       }
       case SMGS: {
         for(int i = 0; i < SMGs.length; i++) {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + i*0.1*height, buttonWidth(), buttonHeight())) {
             game.you.gun = exhibit;
             playsound("overload.wav");
           }
         }
         
         break; 
       }
       case SHOTGUNS: {
         for(int i = 0; i < shotguns.length; i++) {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + i*0.1*height, buttonWidth(), buttonHeight())) {
             game.you.gun = exhibit;
             playsound("overload.wav");
           } 
         }
         break; 
       }
       case RIFLES: {
         for(int i = 0; i < rifles.length; i++) {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + i*0.1*height, buttonWidth(), buttonHeight())) {
             game.you.gun = exhibit;
             playsound("overload.wav");
           } 
         }
         break; 
       }
       case HEAVY: {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height, buttonWidth(), buttonHeight())) {
             game.you.gun = exhibit;
             playsound("overload.wav");
           }          
         break;             
       }
     }  
  }
  
  void moveMouse() {
     switch(shopState) {
       case PISTOLS: {
         if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height, buttonWidth(), buttonHeight())) {
           if(!hovered[0]) {
             hovered[0] = true;
           
             exhibit = new Weapon("pistol"); 
           }
         } else {
           hovered[0] = false; 
         }
         
         break;
       }
       case SMGS: {
         for(int i = 0; i < SMGs.length; i++) {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + i*0.1*height, buttonWidth(), buttonHeight())) {
             if(!hovered[i]) {
               hovered[i] = true;
             
               exhibit = new Weapon(SMGs[i]); 
             }
           } else {
             hovered[i] = false; 
           }
         }
         
         break; 
       }
       case SHOTGUNS: {
         for(int i = 0; i < shotguns.length; i++) {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + i*0.1*height, buttonWidth(), buttonHeight())) {
             if(!hovered[i]) {
               hovered[i] = true;
             
               exhibit = new Weapon(shotguns[i]); 
             }
           } else {
             hovered[i] = false; 
           }
         }
         break; 
       }
       case RIFLES: {
         for(int i = 0; i < rifles.length; i++) {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height + i*0.1*height, buttonWidth(), buttonHeight())) {
             if(!hovered[i]) {
               hovered[i] = true;
             
               exhibit = new Weapon(rifles[i]); 
             }
           } else {
             hovered[i] = false; 
           }
         }
         break; 
       }
       case HEAVY: {
           if(point_in_rect(mouseX, mouseY, 0.15*width, 0.2*height, buttonWidth(), buttonHeight())) {
             if(!hovered[0]) {
               hovered[0] = true;
             
               exhibit = new Weapon("M61Vulcan"); 
             }
           } else {
             hovered[0] = false; 
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
      int _color = hovered[i] ? 140 : 230; ;
      printButton(args[i], 0.15*width, 0.2*height + i*0.1*height, _color);    
      
      if(hovered[i]) 
        showExhibit();
    }  
  }
  
  private void printButton(String text, float x, float y, int _color) {
    fill(255, _color, _color, 150);
    rect(x, y, buttonWidth(), buttonHeight(), 20);
    fill(0);
    text(text, x + 0.5*buttonWidth(), y + 0.5*buttonHeight());  
  }
  
  private void printExit() {
    fill(255, 230, 230, 150);
    rect(0.87*width, 0.1*height, 0.03*width, buttonHeight(), 20);
       
    fill(0);
    text("X", 0.87*width + 0.015*width, 0.1*height + 0.5*buttonHeight());
  }
 
  private void showExhibit() { 
     text("name " + exhibit.name, width/2,height/4);
     text("damage " + exhibit.damage, width/2,height/4 + 50);
     text("accuracy " + int(exhibit.accuracy*100) + "%", width/2,height/4 + 100);
     text("fire rate " + exhibit.fire_rate + " ms", width/2,height/4 + 150);
     text("weight " + int(exhibit.weight*100) + "%", width/2,height/4 + 200);
     text("max ammo " + exhibit.max_ammo, width/2,height/4 + 250);
     text("bullets in shot " + exhibit.multiple, width/2,height/4 + 300);
     text("cost " + exhibit.cost, width/2,height/4 + 350);
  }
}
