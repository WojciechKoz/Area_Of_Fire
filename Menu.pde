class Menu {
  
  Menu() {}
  
  void show() {
    textSize(30);
    background(100, 200, 200);
    fill(255, 0, 0);
    rect(width/2, height/2, 150, 50); 
    fill(0);
    text("Balls", width/2 + 20 , height/2 + 38);
    
    fill(255, 0, 0);
    rect(width/2, height/2 + 70, 150, 50); 
    fill(0);
    text("sandbox", width/2 + 20 , height/2 + 108); 
    
    text("your nick: ", 100, height - 100);
    text(localnick, 250, height - 100);
    fill(255, 0, 0);
    rect(100, height - 80, 100, 40);
    fill(0);
    if(GP == Game_position.input)
      text("accept", 108, height - 50);
    else
      text("change", 102, height - 50);
  }

  void clicks(){
    if(point_in_rect(mouseX, mouseY, width/2, height/2, 150, 50)) {
        miniGame = new Balls();
        GP = Game_position.balls;
      }
      
      if(point_in_rect(mouseX, mouseY, width/2, height/2 + 70, 150, 50)) {
        game = new Game();
        GP = Game_position.game;
      }
      
      if(point_in_rect(mouseX, mouseY, 100, height - 80, 100, 40)) {
        if(GP == Game_position.menu) {
          GP = Game_position.input;
          localnick = ""; 
        }
        else
          GP = Game_position.menu;
 
      }
  }
  void textEdit() {
     if(keyCode == ENTER)
       GP = Game_position.menu;
     if(keyCode == BACKSPACE && localnick.length() > 0) 
       localnick = localnick.substring(0, localnick.length()-1);    
     if((char)key >= 32 && (char)key <= 125)
       localnick += (char)key; 
  }
  
}
