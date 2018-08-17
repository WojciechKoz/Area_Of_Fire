
class Map {
  float _width;
  float _height;
  ArrayList<Player> players = new ArrayList<Player>();
  ArrayList<Wall> walls = new ArrayList<Wall>();
  Point relative = new Point(0,0);
  
  Map() {
    _width = 2500;
    _height = 1000;
    
    walls.add(new Wall(new Point(230, 50), new Point(260, 50), new Point(260, 480)));
    walls.add(new Wall(new Point(260, 50), new Point(800, 50), new Point(800, 80)));
    walls.add(new Wall(new Point(800, 80), new Point(800, 500), new Point(770, 480)));
    walls.add(new Wall(new Point(260, 480), new Point(230, 500), new Point(350, 700))); 
    walls.add(new Wall(new Point(770, 480), new Point(800, 500), new Point(710, 700)));
    walls.add(new Wall(new Point(360, 200), new Point(670, 200), new Point(670, 300)));
  }
  
  void print_map(Player observer) {
     background(0);
     strokeWeight(0);
     fill(27, 168, 0);
     
     relative.x = width/2 - observer.relative.x - observer.x;
     relative.y = height/2 - observer.relative.y - observer.y;
     
     rect(relative.x, relative.y, _width, _height);
     
     for(int i = 1; i < players.size(); i++)
       players.get(i).print_it(relative.x, relative.y);
     
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
  
  void game_frame() {
    background(150, 200, 200);  
    players.get(0).setFalsePos();
    print_map(players.get(0));
    players.get(0).move(); 
  }
    
  void game_keys_down() {
    if(hasKey('a', players.get(0)))
      players.get(0).keys.add('a');
    if(hasKey('d', players.get(0)))
      players.get(0).keys.add('d');
    if(hasKey('w', players.get(0)))
      players.get(0).keys.add('w');
    if(hasKey('s', players.get(0)))
      players.get(0).keys.add('s');
    
      
    if(key == 'q' || key == 'Q')  
      players.get(0).gun = new Weapon("pistol");
  
    if(key == 'm' || key == 'M') {
       GP = Game_position.menu;
       menu();
    }  
    if(keyCode == SHIFT) 
      players.get(0).run = true; 
    if(key == 'c' || key == 'C')
      players.get(0).crouch = true;
    if(key == ' ')
      players.get(0).shoots = true;
  }
  // ####################################  keyUp
  
  void game_keys_up() {
     if(key == 'A' || key == 'a') 
        for(int i = 0; i < players.get(0).keys.size(); i++)
          if((char)players.get(0).keys.get(i) == 'a')
            players.get(0).keys.remove(i);
            
    if(key == 'D' || key == 'd')
       for(int i = 0; i < players.get(0).keys.size(); i++)
          if((char)players.get(0).keys.get(i) == 'd')
            players.get(0).keys.remove(i);
            
    if(key == 'W' || key == 'w')
       for(int i = 0; i < players.get(0).keys.size(); i++)
          if((char)players.get(0).keys.get(i) == 'w')
            players.get(0).keys.remove(i);
            
    if(key == 'S' || key == 's')
       for(int i = 0; i < players.get(0).keys.size(); i++)
          if((char)players.get(0).keys.get(i) == 's')
            players.get(0).keys.remove(i);
            
    if(keyCode == SHIFT) 
      players.get(0).run = false;
    if(key == 'c' || key == 'C')
      players.get(0).crouch = false;
  
    if(key == ' ')
      players.get(0).shoots = false;  
  }
  
  void cut_map(Player observer) {
    // liczmy prawdziwymi wspolrzednymi 
    fill(0);
    
    for(Wall w: walls) {
      w.print_shadow(observer, this);
    } 
  }
}
