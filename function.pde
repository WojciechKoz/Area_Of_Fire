float change_x(float q) {
  if(q  >= width-10  || q  <= 10)
     return -1; 
  return 1;
}

float change_y(float q) {
  if(q  >= height-10  || q  <= 10)
     return -1; 
  return 1;
}

Point sections_intersection(Point A, Point B, Point C, Point D) {
  if(A.x == B.x) {
     float a2 = (D.y - C.y) / (D.x - C.x); 
     float b2 = C.y - a2 * C.x;
     
     float y = a2*A.x + b2;
     
     if(check_inter(A.x, A.y, B.x, B.y, A.x, y) && check_inter(C.x, C.y, D.x, D.y, A.x, y))
       return new Point(A.x, y);
  }
  if(C.x == D.x) {
     float a1 = (B.y - A.y) / (B.x - A.x); 
     float b1 = A.y - a1 * A.x;
     
     float y = a1*C.x + b1;
     
     if(check_inter(A.x, A.y, B.x, B.y, C.x, y) && check_inter(C.x, C.y, D.x, D.y, C.x, y))
       return new Point(C.x, y);
  }
  
  //  
  float a1 = (B.y - A.y) / (B.x - A.x); 
  float b1 = A.y - a1 * A.x;
  
  float a2 = (D.y - C.y) / (D.x - C.x); 
  float b2 = C.y - a2 * C.x;
  
  float x = (b2 - b1) / (a1 - a2);
  float y = a1*x + b1;
  
  if(check_inter(A.x, A.y, B.x, B.y, x, y)) {
      if(check_inter(C.x, C.y, D.x, D.y, x, y)) {
         return new Point(x, y);
      }
  }
  
  return B;
}

float distance(float ax, float ay, float bx, float by) {
  return sqrt((ax - bx) * (ax - bx) + (ay - by) * (ay - by));
}

boolean point_in_circle(Enemy e, float p_x, float p_y) {
  float dist = distance(e.x, e.y, p_x, p_y);
      
  if(dist <= e.radius) 
    return true;
  return false;
}

boolean point_in_rect(float Px, float Py, float Rx, float Ry, float wid, float hei) {
  return (Px > Rx && Px < Rx + wid && Py > Ry && Py < Ry + hei );
}

boolean check_inter(float Ax, float Ay, float Bx, float By, float Cx, float Cy) // sprawdzanie czy krawedz nie nalezy do drugiego odcinka
{
    if(min(Ax, Bx) <= Cx && Cx <= max(Ax, Bx) &&
       min(Ay, By) <= Cy && Cy <= max(Ay, By))
        return true;
        
    if((Cx > Ax - 0.01 && Cx < Ax + 0.01 && min(Ay, By) <= Cy && Cy <= max(Ay, By)) || 
       (Cy > Ay - 0.01 && Cy < Ay + 0.01 && min(Ax, Bx) <= Cx && Cx <= max(Ax, Bx))) // dodane na potrzeby niedokladnosci w liczeniu floatow
      return true;   
      
    return false;
}

boolean line_intersection_with_circle(float Ax,float Ay, float Bx, float By, float Sx, float Sy, float r) {
    float closer_point_dist = min((Ax - Sx)*(Ax - Sx) + (Ay - Sy)*(Ay - Sy),
                              (Bx - Sx)*(Bx - Sx) + (By - Sy)*(By - Sy));       // odleglosc blizszego z punktow A i B

    float further_point_dist = max((Ax - Sx)*(Ax - Sx) + (Ay - Sy)*(Ay - Sy),
                               (Bx - Sx)*(Bx - Sx) + (By - Sy)*(By - Sy));      // odleglosc dalszego z punktow A i B

    if(closer_point_dist == r*r || further_point_dist == r*r) // jesli koniec odcinka lezy na obwodzie to
    {                                              //  odcinek ma punkt przeciecia z okregiem
        return true;
    }
    if(closer_point_dist < r*r && further_point_dist > r*r) // jesli 1 punkt jest wewnatrz kola a drugi nie to
    {                                            // odcinek ma punkt przeciecia z okregiem
        return true;
    }
    // funkcja sprawdzajaca przeciecie pionowych i poziomych lini z kołem
    if(Ay - By == 0) {
      if(Sx > min(Ax, Bx) && Sx < max(Ax, Bx)) {
        if(abs(Sy - Ay) < r)
          return true;
        return false;
      } else {
        return false; 
      }
    }
    
    if(Ax - Bx == 0) {
      if(Sy > min(Ay, By) && Sy < max(Ay, By)) {
        if(abs(Sx - Ax) < r)
          return true;
        return false;
      } else {
        return false; 
      }
    }
      
    float a_stretch = (Ay - By) / (Ax - Bx); // kierunkowa prostej zawierajacej A i B

    float b_stretch = Ay - a_stretch * Ax; // punkt przeciecia tej prostej z OY

    float a = -1 / a_stretch; // kierunkowa prostej prostopadlej do  prostej zawierajacej A i B

    float b = Sy - a * Sx;  // punkt przeciecia z OY

    float x = (b - b_stretch) / (a_stretch - a); // x punktu przeciecia dwoch prostych

    float y = a * x + b; // y przeciecia dwoch prostych

    if(((x - Sx)*(x - Sx) + (y - Sy)*(y - Sy)) <= r*r) // jesli punkt przeciecia jest wew kola lub na obwodzie
    {
        if(check_inter(Ax, Ay, Bx, By, x, y)) // jesli punkt przeciecia lezy na odcinku znaczy ze odcinek przecina okrag
        {
            return true;
        }
    }
    return false;  
}

void bots_moves() {
  for(Enemy b: lvl.enemies) {
    if(b.visible) {
      if(lvl.type != "pause")
        b.move();
        
      b.print_it();
    }
  }
}



void draw_hp(float hp, float max) {
  int g = int(hp/max * 255);
  int r = int(max/hp*130);
  
  stroke(r, g, 20); 
}

void setupsound() {
  ac = new AudioContext();
  ac.start();
}
 
void playsound(String path) {
  if(ac == null) {
    setupsound();
  }
 
  SamplePlayer player = new SamplePlayer(ac, SampleManager.sample(dataPath(path)));
 
  Gain g = new Gain(ac, 2, 0.2);
  g.addInput(player);
  ac.out.addInput(g);
}

int in_range(int min, int max, int value) {
   if(value < min)
     value = min;
   if(value > max)
     value = max;
   return value;
}

boolean hasKey(char k, Player p) {
    return (key == k || key == Character.toUpperCase(k)) && !p.keys.contains(k);
}

void menu() {
  background(100, 200, 200);
  fill(255, 0, 0);
  rect(width/2, height/2, 150, 50); 
  fill(0);
  text("Balls", width/2 + 20 , height/2 + 38);
  
  fill(255, 0, 0);
  rect(width/2, height/2 + 70, 150, 50); 
  fill(0);
  text("sandbox", width/2 + 20 , height/2 + 108); 
}

void menu_clicks(){
  if(point_in_rect(mouseX, mouseY, width/2, height/2, 150, 50)) {
      Bplayer = new BPlayer();
      lvl = new Level(1);
      GP = Game_position.balls;
      loop(); 
    }
    
    if(point_in_rect(mouseX, mouseY, width/2, height/2 + 70, 150, 50)) {
      sandbox = new Map();
      sandbox.players.add(new Player());
      sandbox.players.add(new Player());
      GP = Game_position.game;
      loop(); 
    }     
}
