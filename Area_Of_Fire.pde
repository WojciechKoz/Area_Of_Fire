
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.Clip;
import javax.sound.sampled.UnsupportedAudioFileException;
import javax.sound.sampled.LineUnavailableException;
import beads.*;
 
AudioContext ac;
PFont font;

// parameters
enum Game_position {game, balls, menu};
Game_position GP = Game_position.menu;

Menu main = new Menu(); // menu
Game game;
Balls miniGame;

void setup() { 
  fullScreen(P3D, SPAN);
  background(100, 70, 130);
  cursor(CROSS);
  font = createFont("Arial", 30);
  textFont(font);
 // noLoop();
  main.show();
  
  frameRate(50);
  
  //surface.setResizable(true);
}



void draw() {
  switch(GP) {
    case balls:
      miniGame.frame(); break;
    case game:
      game.frame(); break;
    case menu:
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
      game.keys_down(); 
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
