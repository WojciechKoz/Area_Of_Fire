class RemotePlayer extends Player {
  float network_shadow_x, network_shadow_y;
  ArrayList<Point> shots = new ArrayList<Point>();
  boolean hasReceivedMove = false;

  void receivedMove() {
    if(! hasReceivedMove) {
      // this is the first MOVE message from this player
      hasReceivedMove = true;

      // teleport to location instantly
      x = network_shadow_x;
      y = network_shadow_y;
    }
  }
  
  private void comeBackToLife() {
    Point p = game.map.respawnPoint(team);
    if(p != null) {
      x = p.x;
      y = p.y;
    }
  }
  
  private void died() {
    hasReceivedMove = false;
  }
  
  void setHp(int hp) {
    if(!isAlive() && hp > 0) {
      comeBackToLife();
    }
    
    if(isAlive() && hp <= 0) {
      died();
    }
    
    this.hp = hp;
  }

  void print_it(float imag_x, float imag_y, Map map) {
    if(!hasReceivedMove)
      return;
      
    if(!isAlive())
      return;
    
    float movementSpeed = 250;
   
    if(crouch)
      movementSpeed *= 0.2;
    else if(run)
      movementSpeed *= 1.5;
      
    movementSpeed *= (1-gun.weight);
  
    x = limit(network_shadow_x, (movementSpeed/frameRate), x);
    y = limit(network_shadow_y, (movementSpeed/frameRate), y);
    
    if(team == Teams.RED)
      fill(255, 0, 0);
    else
      fill(0, 0, 255);
      
    draw_hp(hp, max_hp);
    ellipse(imag_x + x, imag_y + y, 2*radius, 2*radius); 
    noStroke();
 
    // draw and play shot effect
    for(Point pt: shots)
      drawShot(map.relative.x + x, map.relative.y + y, map.relative.x + pt.x, map.relative.y + pt.y);
      
    if(!shots.isEmpty()) {
      
      playsound(gun.name + ".wav");
    }  
      
    shots.clear();
  } 

}
