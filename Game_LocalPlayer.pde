class LocalPlayer extends Player {
  ArrayList<Point> shotsPoints = new ArrayList<Point>();
  ArrayList keys = new ArrayList();
  
  LocalPlayer() {
    super();
    this.nick = localnick;
  }
    
  void setFalsePos() {
     relative.x = (width/2 - mouseX)/2;
     relative.y = (height/2 - mouseY)/2;
     relative.x *= -1;
     relative.y *= -1;
  }
  
  void move(Map map) {
    fill(150, 160, 180);
    strokeWeight(4);
    draw_hp(hp, max_hp);
    
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

    if(x + final_delta_x + radius < map._width && x + final_delta_x - radius > 0 && map.empty_space(x + final_delta_x, y, radius))
      x += final_delta_x;
    if(y + final_delta_y + radius < map._height && y + final_delta_y - radius > 0 && map.empty_space(x, y + final_delta_y, radius))
      y += final_delta_y;
      
    print_yourself();
    
    if(shoots) 
      this.shoot(map);
  }
  
  void shoot(Map map) { 
    if(millis() - gun.before > gun.fire_rate && !run) {  
        
      gun.ammo--;
            
      if(gun.ammo < 0 ) {
        gun.ammo = 0;
      //  if(gun.name != "pistol")
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
        Point closerPt = new Point(target_x - map.relative.x, target_y - map.relative.y);
        
        float min_dist = dist(x, y, target_x - map.relative.x, target_y - map.relative.y);
          
        for(Wall w: map.walls) {
           for(int i = 0; i < 3; i++) {
             Point before; 
             
             if(i == 0) {
                before = w.points.get(2);
             } else {
                before = w.points.get(i - 1); 
             }
             
             end = sections_intersection(new Point(x, y), new Point(target_x - map.relative.x, target_y - map.relative.y), w.points.get(i), before);
             float dist = dist(x, y, end.x, end.y);
             
             if(dist < min_dist) {
               min_dist = dist; 
               closerPt = end;

             }
           }
        }
        
        drawShot(map.relative.x + closerPt.x, map.relative.y + closerPt.y, width/2 - relative.x, height/2 - relative.y);
        
        shotsPoints.add(closerPt);

        shoots++;
      } while(shoots < gun.multiple);
      
      gun.before = millis();
    }
  }
  
  void print_yourself() {
     if(team == Teams.RED)
       fill(255, 0, 0);
     else
       fill(0, 0, 255);
     
     ellipse(width/2 - relative.x, height/2 - relative.y, 2*radius, 2*radius); 
  }
  
  void onRespawn(Map map) {
    gun = new Weapon("pistol");
    
    if(team == Teams.RED) {
      x = map.redRespawn.x;
      y = map.redRespawn.y;
    } else {
      x = map.blueRespawn.x;
      y = map.blueRespawn.y;
    }
    keys.clear();
  }
  
  void clearMove() {
     keys.clear();
     shoots = false;
     run = false;
     crouch = false; 
  }
}
