class Point {
   float x, y;
   
   Point(float x, float y) {
      this.x = x;
      this.y = y;
   }
   boolean compare(Point d) {
      return this.x == d.x && this.y == d.y; 
   }
}

class Line {
   float a, b;
   
   Line(float a, float b) {
     this.a = a;
     this.b = b;
   }
   
   void setValues(Point A, Point B) {
     a = (B.y - A.y) / (B.x - A.x); 
     b = A.y - a * A.x; 
   }
   
   float give_y(float x) {
      return a*x + b;
   }
   float give_x(float y) {
      return (y - b) / a; 
   }
}

class Wall {
   ArrayList<Point> points = new ArrayList<Point>();
   
   Wall(Point a, Point b, Point c, Point d) {
     points.add(a);
     points.add(b);
     points.add(c);
     points.add(d);
   }
   
   void print_it(float imag_x, float imag_y) {
     fill(170, 0, 0);
     quad(imag_x + points.get(0).x, imag_y + points.get(0).y, 
          imag_x + points.get(1).x, imag_y + points.get(1).y, 
          imag_x + points.get(2).x, imag_y + points.get(2).y, 
          imag_x + points.get(3).x, imag_y + points.get(3).y); 
   }
   
   void print_shadow(Player observer, Map map) {
     // oblicznia na realnych wspolrzednych
      float max1 = 0; // max1 max2 pamietaja max odleglosci punktow od gracza ktore nie dzieli sciana
      float max2 = 0;
      Point first = new Point(10,10);    // first i second to cornery sciany ktore sa najdalej od gracza a jednoczesnie nie sa zasloniete
      Point second = new Point(10,10);
      
      for(Point corner: points) {
         boolean first_condition = false;    // te warunki spelnia punkt ktorego poloczenie do gracza nie przecina inne polaczenie 2 innych rogow tej sciany 
         boolean second_condition = false;
         
         for(int i = 0; i < 4; i++) {  
            Point before;  // jeden z rogow do stworzenia odcinka ktory moze przeciac odcinek gracza z wybranym punktem (corner)
            
            if(i == 0)
              before = points.get(3);
            else
              before = points.get(i - 1);
              
            if(corner.compare(before) || corner.compare(points.get(i))) {  
               continue;  
            }
            
            if(corner.compare(sections_intersection(new Point(observer.x, observer.y), corner, points.get(i), before))) {
              if(!first_condition)
                first_condition = true;
              else
                second_condition = true;
            }
         }
         if(first_condition && second_condition) {
           float dist = dist(observer.x, observer.y, corner.x, corner.y);
           
           if(dist > max1) {
             max2 = max1;
             max1 = dist;
             second = first;
             first = corner;
           } else if(dist > max2) {
             max2 = dist; 
             second = corner;
           }
           
         }
      }
      Line right = new Line(1,1);
      Line left = new Line(1,1);
      
      left.setValues(new Point(observer.x, observer.y), first);
      right.setValues(new Point(observer.x, observer.y), second);
      
      float first_far_x;
      float second_far_x;
      
      if(first.x > observer.x)
        first_far_x = first.x + 750;
      else
        first_far_x = first.x - 750;
        
      if(second.x > observer.x)
        second_far_x = second.x + 750;
      else
        second_far_x = second.x - 750;
      
      Point third = new Point(second_far_x, right.give_y(second_far_x));
      Point fourth = new Point(first_far_x, left.give_y(first_far_x));
      
     // ellipse(first.x + map.relative.x, first.y + map.relative.y, 10, 10);
     // ellipse(second.x + map.relative.x, second.y + map.relative.y, 10, 10);
     
      
      // uralatywniamy 
      
      quad(first.x + map.relative.x, first.y + map.relative.y, second.x + map.relative.x, second.y + map.relative.y, 
           third.x + map.relative.x, third.y + map.relative.y, fourth.x + map.relative.x, fourth.y + map.relative.y);
   }
}
