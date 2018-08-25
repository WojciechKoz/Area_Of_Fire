class ReceivedPlayerStats {
  int playerId;
  int kills;
  int deaths;
}

class Stats {
  Game game;
  ArrayList<ReceivedPlayerStats> stats;
  
  boolean holding_tab = false;
  
  public Stats(Game game) {
    this.game = game;
  }
  
  public void receivedStats(ArrayList<ReceivedPlayerStats> stats) {
    this.stats = stats;
    
    println("Received stats, len:", stats.size());
    for(ReceivedPlayerStats s : stats) {
      println("Statistics: player =", s.playerId, " kills =", s.kills, " deaths =", s.deaths); 
    }
  }
  
  private String playerIdName(int playerId) {
    Player player = game.getPlayerById(playerId);
    if(player == null || player.nick == null)
      return "???";
    return player.nick;
  }
  
  private Teams playerIdTeam(int playerId) {
    Player player = game.getPlayerById(playerId);
    if(player == null)
      return Teams.NEUTRAL;
    return player.team;
  }
  
  private void drawTeamStats(Teams team, Point topLeft, float w, float h) {
    noStroke();
    if(team == Teams.BLUE)
      fill(color(0x4B, 0x40, 0x62, 213));
    else if(team == Teams.RED)
      fill(color(0x62, 0x46, 0x40, 213));
    
    rect(topLeft.x, topLeft.y, w, h, 10);
    
    textAlign(CENTER, TOP);
    fill(color(255, 255, 255, 220));
    text(team == Teams.RED ? "Team red" : "Team blue", topLeft.x + w/2, topLeft.y + 10);
    
    stroke(color(255, 255, 255, 64));

    line(topLeft.x, topLeft.y + 40, topLeft.x + w, topLeft.y + 40);

    fill(color(255, 255, 255, 220));
    textAlign(CENTER);

    text("K", topLeft.x + w - 60, topLeft.y + 70);
    text("D", topLeft.x + w - 30, topLeft.y + 70);
    
    
    fill(color(255, 255, 255, 210));
    
    int index = 0;
    for(ReceivedPlayerStats playerStats : stats) {
      if(playerIdTeam(playerStats.playerId) != team)
        continue;
      
      index++;
      float offsetY = topLeft.y + 70 + index * 30;
      
      noStroke();
      if(playerStats.playerId == -1) { // us
        fill(color(255, 255, 255, 20));
        rect(topLeft.x + 10, offsetY - 20, w - 20, 28, 5);
      }
      
      fill(color(255, 255, 255));
      textAlign(LEFT);
      text(playerIdName(playerStats.playerId), topLeft.x + 20, offsetY);
      textAlign(CENTER);
      text(playerStats.kills, topLeft.x + w - 60, offsetY);
      text(playerStats.deaths, topLeft.x + w - 30, offsetY);
    }
    
    textAlign(BASELINE);
  }
  
  public void printIfNeeded() {
    if(!holding_tab)
      return;
      
    if(stats == null)
      stats = new ArrayList<ReceivedPlayerStats>();
    
    //line(100, 100 + 40, width - 100, 100 + 40);
    //line(100, 100 + 80, width - 100, 100 + 80);

    drawTeamStats(Teams.BLUE, new Point(100, 150), width / 2 - 100, height - 300);
    
    drawTeamStats(Teams.RED, new Point(width/2, 150), width / 2 - 100, height - 300);
  }
}
