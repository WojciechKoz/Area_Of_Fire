class BPlayer {
  final float radius = 13;
  final int max_hp = 5;
  final float mobility = 250;
  
  float x, y;;
  Weapon gun;
  boolean shoots;
  boolean run;
  boolean crouch;
  
  int hp;
  int a;
  ArrayList keys;
  BPlayer() {
    x = 300;
    y = 300;
    a = 25;
    gun = new Weapon("pistol");
    hp = max_hp;
    keys = new ArrayList();
    run = false;
    crouch = false;
  }
  
  void shoot(Level lvl) { 
    if(millis() - gun.before > gun.fire_rate && !run) {  
      
      miniGame.beginning();
        
      gun.ammo--;
            
      if(gun.ammo < 0 ) {
        gun.ammo = 0;
        if(gun.name != "pistol")
          gun = new Weapon("pistol");
        return;
      }
      
      playsound(gun.name + ".wav");
        
      int shoots = 0;
      do {
        float target_x = mouseX;
        float target_y = mouseY;
        
            
        if(random(0, 1) > gun.accuracy){
            float recoil = 1;
        
            if(crouch){
               recoil = 0.5; 
            }
            if(millis() - gun.before < 1.2*gun.fire_rate) {
               recoil = 1.3*recoil; 
            }
              
            float dist = distance(x, y, mouseX, mouseY);
            target_x += dist/(20*gun.accuracy) * random(-recoil, recoil);
            target_y += dist/(20*gun.accuracy) * random(-recoil, recoil);
        }
          
        
        fill(254, 217, 103);  
        stroke(254, 217, 103);
        strokeWeight(2);
        line(x + a/2, y + a/2, target_x, target_y);
        strokeWeight(0);
        
        for(int i = 0; i < lvl.enemies.size(); i++) { 
          if(!lvl.enemies.get(i).visible)
            continue;
          lvl.enemies.get(i).shooted(x, y, target_x, target_y,gun);
          if(lvl.enemies.get(i).lives <= 0) {
             lvl.enemies.remove(i); 
             lvl.counter --;
          }
        }
        
        if(lvl.counter == 0) {
          miniGame.lvl_up();
        }
        
        shoots++;
      }while(shoots < gun.multiple);
      gun.before = millis();
    }
   
  }
  
  void move(Level lvl) {
    fill(150, 160, 180);
    strokeWeight(4);
    draw_hp(hp, max_hp);
    
    rect(x, y, a, a);
    
    if(miniGame.type == Type.pause)
      return;
    
    boolean x_found = false;
    boolean y_found = false;
    
    float delta_x = 0;
    float delta_y = 0;
    
    for(int i = keys.size()-1; i >=0; i--) {
       // looking for a d
       if((char)keys.get(i) == 'a' && !x_found) {
         x_found = true;
         delta_x = -mobility;
       }
       if((char)keys.get(i) == 'd' && !x_found) {
         x_found = true;
         delta_x = mobility;
       }
       // looking for w s
       if((char)keys.get(i) == 'w' && !y_found) {
         y_found = true;
         delta_y = -mobility;
       }
       if((char)keys.get(i) == 's' && !y_found) {
         y_found = true;
         delta_y = mobility;
       }
    }
    
    float bonus_x = 1;
    float bonus_y = 1;
    
    if(crouch) {
      if(delta_x == mobility || delta_x == -mobility)
        bonus_x = 0.2;

      if(delta_y == mobility || delta_y == -mobility)
        bonus_y = 0.2;

    } else if(run) {
      if(delta_x == mobility || delta_x == -mobility)
        bonus_x = 1.5;

      if(delta_y == mobility || delta_y == -mobility)
        bonus_y = 1.5;

    }
    
    float final_delta_x = (delta_x*(1-gun.weight)) * bonus_x / frameRate;
    float final_delta_y = (delta_y*(1-gun.weight)) * bonus_y / frameRate;

    
    if((x + final_delta_x) < (width - 160 - a) && (x + final_delta_x) > (a/2 + 150))
      x += final_delta_x;
      
    if((y + final_delta_y) < (height - 160 - a) && (y + final_delta_y) > (a/2 + 150))
       y += final_delta_y;
    
    if(shoots) 
      this.shoot(lvl);
  }
  
  void collision(Level lvl) {
    float [] corners_x = {x, x + a, x + a, x};
    float [] corners_y = {y, y, y + a, y + a};
    
    for(int i = 0; i < lvl.enemies.size(); i++) {
      if(!lvl.enemies.get(i).visible)
        continue;
      for(int j = 0; j < 4; j++) 
        if(i < lvl.enemies.size())
          if(point_in_circle(lvl.enemies.get(i),  corners_x[j], corners_y[j])) {
            hp--;
            miniGame.first_shots = 0; 
            miniGame.type = Type.start;
          }
          if(hp <= 0){
             miniGame.game_over();
          }
    }
  }
}
