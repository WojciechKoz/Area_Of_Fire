import java.util.List;
import java.net.URL;
import javax.net.ssl.HttpsURLConnection;
import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.nio.file.Paths;
import java.nio.file.Files;

import java.net.MalformedURLException;
import java.io.IOException;

class AutoUpdate {
  boolean checked = false;
  boolean checkOnNextFrame = false;
  
  private String getLocalVersion() {
    try {
      List<String> lines = Files.readAllLines(Paths.get(dataPath("version")));
      if(lines == null || lines.size() == 0)
        return null;
      return lines.get(0);
    } catch(IOException ex) {
      ex.printStackTrace();
    }
    
    return null;
  }
  
  private String getRemoteVersion() {
    try {
      URL url = new URL("https://area-of-fire.baraniecki.eu/version-all");
      HttpsURLConnection connection = (HttpsURLConnection)url.openConnection();
      BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
      
      return reader.readLine();
    } catch(MalformedURLException ex) {
      ex.printStackTrace();
    } catch(IOException ex) {
      ex.printStackTrace();
    }
    return null;
  }
  
  private boolean hasLatestVersion() {
    String remoteVer = getRemoteVersion();
    String localVer = getLocalVersion();

    println(remoteVer, localVer);
    
    if(localVer == null || remoteVer == null)
      return true;
    
    return remoteVer.equals(localVer);
  }
  
  private void update() {
    println("Starting an update");
    
    try {
      boolean windows = File.separatorChar == '\\';
      String extension = windows ? ".bat" : "";
      
      exec(dataPath("") + File.separator + ".." + File.separator + "updater" + File.separator + "update" + extension);
    } catch(Exception ex) {
      ex.printStackTrace(); 
    }
    
    exit();
  }
  
  private void check() {
    if(hasLatestVersion()) {
      GP = Game_position.menu;
    } else {
      update();
    }
  }
  
  public void draw() {
    background(100, 200, 200);
    textAlign(CENTER, CENTER);
    text("Checking for updates", width / 2, height / 2);
    textAlign(BASELINE);
    
    if(checkOnNextFrame) {
      check();
      checkOnNextFrame = false;
      return;
    }
    
    if(!checked) {
      checked = true;
      checkOnNextFrame = true;
      return;
    }
  }
}
