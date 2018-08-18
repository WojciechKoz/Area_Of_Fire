class Menu {
  Menu() {}
  
  void show() {
    background(100, 200, 200);
    fill(255, 0, 0);
    rect(width/2, height/2, 150, 50); 
    fill(0);
    text("Balls", width/2 + 20 , height/2 + 38);
    
    fill(255, 0, 0);
    rect(width/2, height/2 + 70, 150, 50); 
    fill(0);
    text("sandbox", width/2 + 20 , height/2 + 108); 
}

void clicks(){
  if(point_in_rect(mouseX, mouseY, width/2, height/2, 150, 50)) {
      miniGame = new Balls();
      GP = Game_position.balls;
      loop(); 
    }
    
    if(point_in_rect(mouseX, mouseY, width/2, height/2 + 70, 150, 50)) {
      game = new Game();
      GP = Game_position.game;
      loop(); 
    }     
  }
  
}
