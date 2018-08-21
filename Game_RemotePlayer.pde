class RemotePlayer extends Player {
  float network_shadow_x, network_shadow_y;
  ArrayList<Point> shots = new ArrayList<Point>();

  void print_it(float imag_x, float imag_y, Map map) {
    float movementSpeed = 250;
   
    if(crouch)
      movementSpeed *= 0.2;
    else if(run)
      movementSpeed *= 1.5;
      
    movementSpeed *= (1-gun.weight);
  
    x = limit(network_shadow_x, (movementSpeed/frameRate), x);
    y = limit(network_shadow_y, (movementSpeed/frameRate), y);
   
    fill(255, 0, 0);
    ellipse(imag_x + x, imag_y + y, 2*radius, 2*radius); 
 
    for(Point pt: shots)
      drawShot(map.relative.x + x, map.relative.y + y, map.relative.x + pt.x, map.relative.y + pt.y);
    shots.clear();
  } 

}
