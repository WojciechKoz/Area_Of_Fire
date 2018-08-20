
class Map {
  float _width;
  float _height;
  ArrayList<Wall> walls = new ArrayList<Wall>();
  Point relative = new Point(0,0);
  
  void add_rect(Point corner1, Point corner2) {
    walls.add(new Wall(corner1, new Point(corner2.x, corner1.y), corner2));
    walls.add(new Wall(corner2, new Point(corner1.x, corner2.y), corner1));
  }
  
  Map() {
    _width = 2500;
    _height = 1000;
    add_rect(new Point(230, 50), new Point(260, 480) );
    add_rect(new Point(260, 50), new Point(800, 80)  );
    add_rect(new Point(800, 80),  new Point(770, 480));
    add_rect(new Point(260, 480), new Point(350, 700)); 
    add_rect(new Point(770, 480), new Point(710, 700));
    add_rect(new Point(360, 200), new Point(670, 300));
  }
  
  void print_map(Player observer) {
     background(0);
     strokeWeight(0);
     fill(27, 168, 0);
     
     relative.x = width/2 - observer.relative.x - observer.x;
     relative.y = height/2 - observer.relative.y - observer.y;
     
     rect(relative.x, relative.y, _width, _height);
     
     cut_map(observer);
     
     for(Wall w: walls)
       w.print_it(relative.x, relative.y);
  }
  
  boolean empty_space(float Px, float Py, float r) {
    for(Wall w: walls) {
      for(int i = 0; i < 3; i++) {
        Point before; 
        
        if(i == 0) {
           before = w.points.get(2);
        } else {
           before = w.points.get(i - 1); 
        }
        
        if(line_intersection_with_circle(before.x, before.y, w.points.get(i).x, w.points.get(i).y, Px, Py, r)) {
           return false; 
        }
      }
    }  
    return true;
  }

  void cut_map(Player observer) {
    // liczmy prawdziwymi wspolrzednymi 
    fill(0);
    
    for(Wall w: walls) {
      w.print_shadow(observer, this);
    } 
  }
}
