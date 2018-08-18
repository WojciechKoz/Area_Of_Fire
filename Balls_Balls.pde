
abstract class Enemy {
  float x, y;
  float radius;
  int lives;
  float delta_x, delta_y;
  boolean visible = true;
  int max_hp;
  float mobility;
  
  void shooted(float player_x, float player_y, float t_x, float t_y, Weapon gun) {
    if(line_intersection_with_circle(player_x, player_y, t_x, t_y, x, y, radius)) {
      lives -= gun.damage;
      fill(255, 0, 0);
      ellipse(x, y, radius*2, radius*2);
    }
  }
  abstract void print_it(Level lvl);
  abstract void move();
  abstract void showing_up(float r, int mx, float new_x, float new_y, int i);
}

class Ball extends Enemy{
  Ball() {
    radius = random(7, 15);
    x = random(radius + 10, width - radius - 10);
    y = random(radius + 10, height - radius - 10);
    delta_x = random(-250, 250);
    delta_y = random(-250, 250);
    
    max_hp = 5;
    lives = max_hp;
  }
  
  void move() {
    delta_x *= change_x(x);
    delta_y *= change_y(y);
    
    x = x + delta_x/frameRate;
    y = y + delta_y/frameRate;   
  }
  
  void showing_up(float r, int mx, float new_x, float new_y, int i){
   // visible = true;
  }
  
  void print_it(Level lvl) {
    strokeWeight(2);
    fill(10, 176, 255);
    draw_hp(lives, max_hp);
    ellipse(x, y, radius*2, radius*2);
  }
  
}

class Crazy extends Enemy {
  
  Crazy() {
    radius = random(10, 12);
    x = int(random(radius, width - radius));
    y = int(random(radius, height - radius));
    delta_x = random(-200, 200);
    delta_y = random(-200, 200);
    
    max_hp = 3;
    mobility = 200;
    lives = max_hp;
  }
  
  void showing_up(float r, int mx, float new_x, float new_y, int i){
   // visible = true;
  }
  
  void move() {
    float rand = random(0, 1);
    
    if(rand > 0.5) {
      delta_x += random(-50, 50);
      delta_y += random(-50, 50);
    }
    if(delta_x > mobility)
      delta_x = mobility;
    if(delta_x < -mobility)
      delta_x = -mobility;
    if(delta_y < -mobility)
      delta_y = -mobility;
    if(delta_y < -mobility)
      delta_y = -mobility;
      
    if(x + delta_x/frameRate > 0 && x + delta_x/frameRate < width)
      x = x + delta_x/frameRate;
    else
      delta_x *= -1;
      
    if(y + delta_y/frameRate > 0 && y + delta_y/frameRate < height) 
      y = y + delta_y/frameRate;
    else   
      delta_y *= -1;

  }
  
  void print_it(Level lvl) {
    strokeWeight(2);
    fill(255, 20, 220);
    draw_hp(lives, max_hp);
    ellipse(x, y, radius*2, radius*2);
  }
}

class DivBoss extends Enemy {
   int index;
   
   DivBoss(float r, int hp, float randx, float randy, int i) {
    radius = r;
    x = randx;
    y = randy;
    delta_x = random(-400, 400);
    delta_y = random(-400, 400);
    
    index = 2*i + 1;
    mobility = 400;
    lives = hp;
    max_hp = hp;
   }
   
   void showing_up(float r, int mx, float new_x, float new_y, int i) {
     radius = int(r/2);
     max_hp = mx/2;
     
     x = new_x;
     y = new_y;
     
     lives = max_hp;
     visible = true;
   }
   
   void divide(Level lvl) {
     if(max_hp > 26) { 
         lvl.enemies.get(index).showing_up(radius, max_hp, x, y, index);
         lvl.enemies.get(index+1).showing_up(radius, max_hp, x, y, index);
       }
       visible = false;
       lvl.counter--;
   }
   
   void print_it(Level lvl) {
    if(lives < max_hp/2 && lives != 1) 
       divide(lvl);
    strokeWeight(2);
    fill(0, 0, 0);
    
    draw_hp(lives/2, max_hp/2);
         
    ellipse(x, y, radius*2, radius*2);
  }
  void move() {
    float rand = random(0, 1);
    
    if(rand > 0.5) {
      delta_x += random(-50, 50);
      delta_y += random(-50, 50);
    }
    if(delta_x > mobility)
      delta_x = mobility;
    if(delta_x < -mobility)
      delta_x = -mobility;
    if(delta_y < -mobility)
      delta_y = -mobility;
    if(delta_y < -mobility)
      delta_y = -mobility;
      
    if(x + delta_x/frameRate - radius > 0 && x + delta_x/frameRate + radius < width)
      x = x + delta_x/frameRate;
    else
      delta_x *= -1;
      
    if(y + delta_y/frameRate - radius > 0 && y + delta_y/frameRate + radius < height) 
      y = y + delta_y/frameRate;
    else   
      delta_y *= -1;

  }
}
