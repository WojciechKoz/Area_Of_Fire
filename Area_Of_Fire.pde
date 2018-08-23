
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.Clip;
import javax.sound.sampled.UnsupportedAudioFileException;
import javax.sound.sampled.LineUnavailableException;
import beads.*;
 
AudioContext ac;
PFont font;


// parameters
enum Game_position {game, balls, menu, input};
Game_position GP = Game_position.menu;

String localnick = "default";

Menu main = new Menu(); 
Game game;
Balls miniGame;

void setup() { 
  //fullScreen(P3D, SPAN);
  size(900, 700, P2D); // trudno testować multiplayer na fullscreenie
  font = createFont("Arial", 30);
  background(100, 70, 130);
  cursor(CROSS);
  textFont(font);
  main.show();
  
  frameRate(50);
  
  surface.setResizable(true);
}



void draw() {
  switch(GP) {
    case balls:
      miniGame.frame(); break;
    case game:
      game.frame(); break;
    case menu:
    case input:
      main.show();
  }
}

void mouseReleased() {
  switch(GP) {
     case balls:
       miniGame.player.shoots = false; break;
     case game:
        game.you.shoots = false;
  }
}

void mousePressed() {
  switch(GP) {
     case menu: 
     case input:
       main.clicks();break;
     case balls:
       miniGame.player.shoots = true; break;
     case game:
        game.you.shoots = true;
  }
}

void keyPressed() {
  switch(GP) {
    case balls:
      miniGame.keys_down(); break;
    case game:
      game.keys_down(); break;
    case input:
      main.textEdit();    
  }


}

void keyReleased() {
  switch(GP) {
    case balls:
      miniGame.keys_up(); break;
    case game:
      game.keys_up(); 
  }
}


void keyTyped(KeyEvent ev) {
  switch(GP) {
    case game:
      game.keys_typed(ev);
  }
}
