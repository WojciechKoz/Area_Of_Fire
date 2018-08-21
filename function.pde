float bounce(float q, float min, float max) {
  if(q  >= max || q  <= min) // width - 10 , 10
     return -1; 
  return 1;
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


boolean hasKey(char k, BPlayer p) {
  return (key == k || key == Character.toUpperCase(k)) && !p.keys.contains(k);
}

boolean hasKey(char k, LocalPlayer p) {
    return (key == k || key == Character.toUpperCase(k)) && !p.keys.contains(k);
}

void drawShot(float x1, float y1, float x2, float y2) {
  fill(254, 217, 103);    
  stroke(254, 217, 103);  
  strokeWeight(2);
  
  line(x1, y1, x2, y2);
  
  strokeWeight(0); 
}
