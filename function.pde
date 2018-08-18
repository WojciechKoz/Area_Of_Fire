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


boolean hasKey(char k, Player p) {
    return (key == k || key == Character.toUpperCase(k)) && !p.keys.contains(k);
}
