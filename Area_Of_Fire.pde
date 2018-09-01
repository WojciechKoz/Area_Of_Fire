
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.Clip;
import javax.sound.sampled.UnsupportedAudioFileException;
import javax.sound.sampled.LineUnavailableException;
import beads.*;
 
AudioContext ac;
PFont font;


// parameters
enum Game_position {autoupdate, game, balls, menu, input};
Game_position GP = Game_position.autoupdate;

String localnick = "default";

Menu main = new Menu(); 
Game game;
Balls miniGame;
AutoUpdate autoupdate = new AutoUpdate();

void setup() { 
  //fullScreen(P3D, SPAN);
  size(1000, 800, P2D); // trudno testować multiplayer na fullscreenie
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
      main.show(); break;
    case autoupdate:
      autoupdate.draw(); break;
  }
}

void mouseReleased() {
  switch(GP) {
     case balls:
       miniGame.player.shoots = false; break;
     case game:
       game.mouseUp(); 
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
       game.mouseDown(); 
  }
}

void mouseMoved() {
  switch(GP) {
     case game:
       game.mouseMove(); break;
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


void keyTyped(processing.event.KeyEvent ev) {
  switch(GP) {
    case game:
      game.keys_typed(ev);
  }
}
