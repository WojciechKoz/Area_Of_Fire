class Player {
  float x, y, a;
  float delta_x, delta_y;
  ArrayList keys;
  Weapon gun;
  boolean shoots;
  boolean run;
  boolean crouch;
  int hp;
  int max_hp;
  float mobility;
  Point relative = new Point(0,0);
  
  Player() {
    x = 300;
    y = 330;
    a = 25;
    delta_x = 0; 
    delta_y = 0;
    gun = new Weapon("pistol");
    max_hp = 5;
    hp = max_hp;
    keys = new ArrayList();
    run = false;
    crouch = false;
    
    mobility = 250;
  }
  
  void shoot() { 
    if(millis() - gun.before > gun.fire_rate && !run) {  
        
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
              
            float dist = distance(mouseX, mouseY, width/2 - relative.x, height/2 - relative.y);
            target_x += dist/(20*gun.accuracy) * random(-recoil, recoil);
            target_y += dist/(20*gun.accuracy) * random(-recoil, recoil);
        }
        Point end;
        Point closerPt = new Point(target_x - sandbox.relative.x, target_y - sandbox.relative.y);
        
        float min_dist = dist(x, y, target_x - sandbox.relative.x, target_y - sandbox.relative.y);
          
        for(Wall w: sandbox.walls) {
           for(int i = 0; i < 3; i++) {
             Point before; 
             
             if(i == 0) {
                before = w.points.get(2);
             } else {
                before = w.points.get(i - 1); 
             }
             
             end = sections_intersection(new Point(x, y), new Point(target_x - sandbox.relative.x, target_y - sandbox.relative.y), w.points.get(i), before);
             float dist = dist(x, y, end.x, end.y);
             
             if(dist < min_dist) {
               min_dist = dist; 
               closerPt = end;

             }
           }
        }
        
        fill(254, 217, 103);  
        stroke(254, 217, 103);
        strokeWeight(2);
        line(sandbox.relative.x + closerPt.x, sandbox.relative.y + closerPt.y, width/2 - relative.x, height/2 - relative.y);
        strokeWeight(0);

        shoots++;
      }while(shoots < gun.multiple);
      gun.before = millis();
    }
  }
  
  void move() {
    fill(150, 160, 180);
    strokeWeight(4);
    draw_hp(hp, max_hp);
    
    boolean x_found = false;
    boolean y_found = false;
    
    delta_x = 0;
    delta_y = 0;
    
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

    if(x + final_delta_x + a/2 < sandbox._width && x + final_delta_x - a/2 > 0 && sandbox.empty_space(x + final_delta_x, y, a/2))
      x += final_delta_x;
    if(y + final_delta_y + a/2 < sandbox._height && y + final_delta_y - a/2 > 0 && sandbox.empty_space(x, y + final_delta_y, a/2))
      y += final_delta_y;
      
    print_yourself();
    
    if(shoots) 
      this.shoot();
  }
  
  void setFalsePos() {
     relative.x = (width/2 - mouseX)/2;
     relative.y = (height/2 - mouseY)/2;
     relative.x *= -1;
     relative.y *= -1;
  }
  
  void print_yourself() {
     fill(255, 0, 0);
     
     ellipse(width/2 - relative.x, height/2 - relative.y, a, a); 
  }
  
  void print_it(float imag_x, float imag_y) {
     fill(255, 0, 0);
     ellipse(imag_x + x, imag_y + y, a, a); 
  }
  
  void collision() {}
   
}
