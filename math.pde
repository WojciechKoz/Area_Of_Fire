
Point line_intersection_with_section(Point A, Point B, Point C, Point D) {
  if(A.x == B.x) {
     float a2 = (D.y - C.y) / (D.x - C.x); 
     float b2 = C.y - a2 * C.x;
     
     float y = a2*A.x + b2;
     
     if(check_inter(C.x, C.y, D.x, D.y, A.x, y))
       return new Point(A.x, y);
  }
  if(C.x == D.x) {
     float a1 = (B.y - A.y) / (B.x - A.x); 
     float b1 = A.y - a1 * A.x;
     
     float y = a1*C.x + b1;
     
     if(check_inter(C.x, C.y, D.x, D.y, C.x, y))
       return new Point(C.x, y);
  }
  
  //  
  float a1 = (B.y - A.y) / (B.x - A.x); 
  float b1 = A.y - a1 * A.x;
  
  float a2 = (D.y - C.y) / (D.x - C.x); 
  float b2 = C.y - a2 * C.x;
  
  float x = (b2 - b1) / (a1 - a2);
  float y = a1*x + b1;
  
  if(check_inter(C.x, C.y, D.x, D.y, x, y)) {
     return new Point(x, y);
  }
  
  return B;
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

float in_range(float min, float max, float value) {
   if(value < min)
     value = min;
   if(value > max)
     value = max;
   return value;
}

Point movePoint(float x, float y, float a, float R)
{
    return new Point((x + cos(a) * R), (y + sin(a) * R));
}

float absIncrement(float value, final float inc) {
   if(value >= 0)
     value += inc;
   if(value < 0)
     value -= inc;
   return value;
}

float limit(float to, float absoluteStep, float from) {
  float step = (from > to) ? -absoluteStep : absoluteStep;
  
  float result = from;
  
  result += step;
  
  if(abs(from - to) < absoluteStep)
    result = to;
    
  return result;   
}
