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
   
   Wall(Point a, Point b, Point c) {
     points.add(a);
     points.add(b);
     points.add(c);
   }
   
   void print_it(float imag_x, float imag_y) {
     fill(170, 0, 0);
     triangle(imag_x + points.get(0).x, imag_y + points.get(0).y, 
              imag_x + points.get(1).x, imag_y + points.get(1).y, 
              imag_x + points.get(2).x, imag_y + points.get(2).y); 
   }
   
   void print_shadow(Player observer, Map map) {
     // oblicznia na realnych wspolrzednych
      Point first = new Point(-10,-10);    // first i second to cornery sciany ktore sa najdalej od gracza a jednoczesnie nie sa zasloniete
      Point second = new Point(10,10);
      
      for(Point corner: points) {
         boolean condition = false;    // te warunki spelnia punkt ktorego poloczenie do gracza nie przecina inne polaczenie 2 innych rogow tej sciany 

         
         for(int i = 0; i < 3; i++) {  
            Point before;  // jeden z rogow do stworzenia odcinka ktory moze przeciac odcinek gracza z wybranym punktem (corner)
            
            if(i == 0)
              before = points.get(2);
            else
              before = points.get(i - 1);
              
            if(corner.compare(before) || corner.compare(points.get(i))) {  
               continue;  
            }
            
            if(corner.compare(line_intersection_with_section(new Point(observer.x, observer.y), corner, points.get(i), before))) {
              if(!condition)
                condition = true;

            }
         }
         if(condition) {
           
           if(first.x == -10) {
             first = corner;
           } else  {
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
      
      int end_of_shadow_value = 10000;
      
      if(first.x > observer.x) {
        first_far_x = first.x + end_of_shadow_value;
      } 
      else {
        first_far_x = first.x - end_of_shadow_value;     
      }
      
      if(second.x > observer.x) {
        second_far_x = second.x + end_of_shadow_value;
      } 
      else {
        second_far_x = second.x - end_of_shadow_value;      
      }
      
      
      
      Point third = new Point(second_far_x, right.give_y(second_far_x));
      Point fourth = new Point(first_far_x, left.give_y(first_far_x));
      

     // ellipse(first.x + map.relative.x, first.y + map.relative.y, 10, 10);
     // ellipse(second.x + map.relative.x, second.y + map.relative.y, 10, 10);
     
      
      // uralatywniamy 
      quad(first.x + map.relative.x, first.y + map.relative.y, second.x + map.relative.x, second.y + map.relative.y, 
           third.x + map.relative.x, third.y + map.relative.y, fourth.x + map.relative.x, fourth.y + map.relative.y);
   }
}
