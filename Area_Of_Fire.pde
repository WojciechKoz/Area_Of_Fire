
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

Player Bplayer;


Level lvl;
Map sandbox;

void setup() { 
  fullScreen(P3D, SPAN);
  background(100, 70, 130);
  cursor(CROSS);
  font = createFont("Arial", 30);
  textFont(font);
  noLoop();
  menu();
  
  frameRate(50);
  
  //surface.setResizable(true);
}



void draw() {
  switch(GP) {
    case balls:
      lvl.ball_frame(); break;
    case game:
      sandbox.game_frame(); 
  }
}

void mouseReleased() {
  switch(GP) {
     case balls:
       Bplayer.shoots = false; break;
     case game:
        sandbox.players.get(0).shoots = false;
  }
}

void mousePressed() {
  switch(GP) {
     case menu: 
       menu_clicks();break;
     case balls:
       Bplayer.shoots = true; break;
     case game:
        sandbox.players.get(0).shoots = true;
  }
}

void keyPressed() {
  switch(GP) {
    case balls:
      lvl.ball_keys_down(); break;
    case game:
      sandbox.game_keys_down(); 
  }


}

void keyReleased() {
  switch(GP) {
    case balls:
      lvl.ball_keys_up(); break;
    case game:
      sandbox.game_keys_up(); 
  }
}
