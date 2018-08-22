var { max, min, sqrt, sin, cos, abs } = Math;

function Point(x, y) {
    this.x = x;
    this.y = y;
}

function line_intersection_with_section(A, B, C, D) {
  if(A.x == B.x) {
     var a2 = (D.y - C.y) / (D.x - C.x); 
     var b2 = C.y - a2 * C.x;
     
     var y = a2*A.x + b2;
     
     if(check_inter(C.x, C.y, D.x, D.y, A.x, y))
       return new Point(A.x, y);
  }
  if(C.x == D.x) {
     var a1 = (B.y - A.y) / (B.x - A.x); 
     var b1 = A.y - a1 * A.x;
     
     var y = a1*C.x + b1;
     
     if(check_inter(C.x, C.y, D.x, D.y, C.x, y))
       return new Point(C.x, y);
  }
  
  //  
  var a1 = (B.y - A.y) / (B.x - A.x); 
  var b1 = A.y - a1 * A.x;
  
  var a2 = (D.y - C.y) / (D.x - C.x); 
  var b2 = C.y - a2 * C.x;
  
  var x = (b2 - b1) / (a1 - a2);
  var y = a1*x + b1;
  
  if(check_inter(C.x, C.y, D.x, D.y, x, y)) {
     return new Point(x, y);
  }
  
  return B;
}

function line_intersection_with_circle(Ax, Ay, Bx, By, Sx, Sy, r) {
    var closer_point_dist = min((Ax - Sx)*(Ax - Sx) + (Ay - Sy)*(Ay - Sy),
                              (Bx - Sx)*(Bx - Sx) + (By - Sy)*(By - Sy));       // odleglosc blizszego z punktow A i B

    var further_point_dist = max((Ax - Sx)*(Ax - Sx) + (Ay - Sy)*(Ay - Sy),
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
      
    var a_stretch = (Ay - By) / (Ax - Bx); // kierunkowa prostej zawierajacej A i B

    var b_stretch = Ay - a_stretch * Ax; // punkt przeciecia tej prostej z OY

    var a = -1 / a_stretch; // kierunkowa prostej prostopadlej do  prostej zawierajacej A i B

    var b = Sy - a * Sx;  // punkt przeciecia z OY

    var x = (b - b_stretch) / (a_stretch - a); // x punktu przeciecia dwoch prostych

    var y = a * x + b; // y przeciecia dwoch prostych

    if(((x - Sx)*(x - Sx) + (y - Sy)*(y - Sy)) <= r*r) // jesli punkt przeciecia jest wew kola lub na obwodzie
    {
        if(check_inter(Ax, Ay, Bx, By, x, y)) // jesli punkt przeciecia lezy na odcinku znaczy ze odcinek przecina okrag
        {
            return true;
        }
    }
    return false;  
}


function check_inter(Ax, Ay, Bx, By, Cx, Cy) // sprawdzanie czy krawedz nie nalezy do drugiego odcinka
{
    if(min(Ax, Bx) <= Cx && Cx <= max(Ax, Bx) &&
       min(Ay, By) <= Cy && Cy <= max(Ay, By))
        return true;
        
    if((Cx > Ax - 0.01 && Cx < Ax + 0.01 && min(Ay, By) <= Cy && Cy <= max(Ay, By)) || 
       (Cy > Ay - 0.01 && Cy < Ay + 0.01 && min(Ax, Bx) <= Cx && Cx <= max(Ax, Bx))) // dodane na potrzeby niedokladnosci w liczeniu floatow
      return true;   
      
    return false;
}

function movePoint(x, y, a, R) {
    return new Point((x + cos(a) * R), (y + sin(a) * R));
}

module.exports = {
    Point,
    line_intersection_with_section,
    check_inter,
    line_intersection_with_circle,
    movePoint,
}
