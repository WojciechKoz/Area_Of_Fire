class RemotePlayer extends Player {
  float network_shadow_x, network_shadow_y;

  void print_it(float imag_x, float imag_y) {
    float movementSpeed = 250;
   
    if(crouch)
      movementSpeed *= 0.2;
    else if(run)
      movementSpeed *= 1.5;
  
    x = limit(network_shadow_x, (movementSpeed/frameRate), x);
    y = limit(network_shadow_y, (movementSpeed/frameRate), y);
   
    fill(255, 0, 0);
    ellipse(imag_x + x, imag_y + y, 2*radius, 2*radius); 
  } 

}
