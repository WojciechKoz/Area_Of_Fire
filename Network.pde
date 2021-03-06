import processing.net.*;

import org.msgpack.core.MessagePack;
import org.msgpack.core.MessagePacker;
import org.msgpack.core.MessageUnpacker;
import org.msgpack.value.ImmutableValue;

interface MessageReceiver {    
   void receivedNewPlayer(int playerId, String name); 
   void receivedMovePlayer(int playerId, float x, float y, boolean crouch, boolean run, int gunId);
   void receivedShot(int playerId, ArrayList<Point> endsOfShots);
   void receivedSetHp(int playerId, int hp, int shooterId);
   void receivedSetHp(int playerId, int hp);
   void receivedDisconnect(int playerId);
   void receivedChatMessage(String msg);
   void receivedColor(int playerId, int teamColor);
   void receivedStats(ArrayList<ReceivedPlayerStats> stats);
}

private enum ReceivedMessageType {
  NEW_PLAYER,
  PLAYER_MOVE,
  SHOT,
  SET_HP,
  DISCONNECT,
  CHAT,
  TEAM,
  STATS,
}

class Network {
    private final int SEND_SET_NICKNAME = 0;
    private final int SEND_MOVE = 1;
    private final int SEND_SHOT = 2;
    private final int SEND_CHAT = 3;
    private final int SEND_COLOR = 4;
    private final int SEND_RESPAWN = 5;
    
    private final int BUFFER_LEN = 4096;
  
    private byte[] buffer = new byte[BUFFER_LEN];
    
    private final long MAX_MS_BETWEEN_SENT_MESSAGES = 5000;
    private long lastSentMessageTime;

    private Client client;
  
    private MessageReceiver mr;
    
    MessagePacker packer;
    
    private ReceivedMessageType[] messageTypeValues = ReceivedMessageType.values();
    
    private void updateLastSent() {
      lastSentMessageTime = System.currentTimeMillis();
    }
    
    private void sendNickname(String nickname) throws IOException {
      updateLastSent();
      
      packer.packArrayHeader(2);
      packer.packInt(SEND_SET_NICKNAME);
      packer.packString(nickname);
      packer.flush();
    }
    
    private void packShots(ArrayList<Point> endsOfBullet) {
      for(Point pt: endsOfBullet) {
        try {
          packer.packFloat(pt.x);
          packer.packFloat(pt.y);
        } catch (IOException ex) {
          println("Failed sending a shots packet");
          ex.printStackTrace();
        }
      }
      endsOfBullet.clear();
    }
    
    public void sendChatMessage(String msg) {
      updateLastSent();
      
      try {
        packer.packArrayHeader(2);
        packer.packInt(SEND_CHAT);
        packer.packString(msg);
        packer.flush();
      } catch(IOException ex) {
        println("Failed sending a chat message");
        ex.printStackTrace();
      }
    }
      
    public void sendTeamColor(int teamColor) {
      updateLastSent();
      
      try {
        packer.packArrayHeader(2);
        packer.packInt(SEND_COLOR);
        packer.packInt(teamColor);
        packer.flush();
      } catch(IOException ex) {
        println("Failed sending a TEAM message");
        ex.printStackTrace();
      }
    }
    
    public void sendRespawn() {
      updateLastSent();
      
      try {
        packer.packArrayHeader(2);
        packer.packInt(SEND_RESPAWN); // (int = 5)
        packer.packArrayHeader(0);
        packer.flush();
      } catch(IOException ex) {
        println("Failed sending a RESPAWN message");
        ex.printStackTrace();
      }
    }
    
    public void sendState(float x, float y, boolean crouch, boolean run, int gunId, ArrayList<Point> endsOfBullet) {
      updateLastSent();
    
      if(! client.active()) {
        println("Not connected");
        return;
      }     
      
      short flags = 0;
      flags |= ((crouch ? 1 : 0) << 0);
      flags |= ((run ? 1 : 0) << 1);
      
      try {
        packer.packArrayHeader(endsOfBullet.size() > 0 ? 4 : 2);
        
        packer.packInt(SEND_MOVE);
        packer.packArrayHeader(4); 
        packer.packFloat(x); 
        packer.packFloat(y); 
        packer.packShort(flags); 
        packer.packInt(gunId);
        
        if(endsOfBullet.size() > 0) {
          packer.packInt(SEND_SHOT);
          packer.packArrayHeader(endsOfBullet.size() * 2);
          packShots(endsOfBullet); 
        }
        
        packer.flush();
      } catch (IOException ex) {
        println("Failed sending a move packet");
        ex.printStackTrace();
      }
    }
    
    private void sendPing() {
      updateLastSent();
      
      println("sending ping!");
      
      try {
        packer.packArrayHeader(0);
        packer.flush();
      } catch(IOException ex) {
        println("Failed sending a ping packet"); 
      }
    }
    
    public void close() {
      if(client.active())
        client.stop();
    }
    
    Network(MessageReceiver mr, String nickname) {
      this.mr = mr;
      client = new Client(Area_Of_Fire.this, "area-of-fire.baraniecki.eu", 7543);
      
      if(!client.active()) {
        println("Could not connect to server");
        return;
      }
      
      packer = MessagePack.newDefaultPacker(client.output);
      
      try {
        sendNickname(nickname);
      } catch(IOException e) {
        println("Exception while sending nickname, disconnecting");
        e.printStackTrace();
        client.stop();
      }
    }
    
    private void pingIfNeeded() {
      if(System.currentTimeMillis() > lastSentMessageTime + MAX_MS_BETWEEN_SENT_MESSAGES) {
        sendPing();
      }
    }
    
    public void tick() {
      pingIfNeeded();
      
      while(client.available() > 0) {
        int read = client.readBytes(buffer);
        try {
          MessageUnpacker unpacker = MessagePack.newDefaultUnpacker(buffer, 0, read);
          while(unpacker.hasNext()) {
            unpackMessage(unpacker);
          }
        } catch(IOException ex) {
          ex.printStackTrace();
        }
      }  
    }
    
    private void unpackMessage(MessageUnpacker unpacker) throws IOException {
       
      /*
       print("Got message: ");
       for(int i = 0; i < len; i++) {
          print(buffer[i], " ");
       }
       println("");
       */
       
       int mapLength = unpacker.unpackArrayHeader() / 2;
       for(int i = 0; i < mapLength; i++) {
           int messageTypeIndex = unpacker.unpackInt();
          // println("recv message type: ", messageTypeIndex);
           
           if(messageTypeIndex < 0 || messageTypeIndex >= messageTypeValues.length) {
              println("Wrong message type: ", messageTypeIndex); 
              return;
           }
           
           ReceivedMessageType msgType = messageTypeValues[messageTypeIndex];
           try {
             handleSingleMessage(msgType, unpacker);
           } catch(IOException ex) {
              ex.printStackTrace();
              return;
           }
       }
    }
    
    private float unpackFloat(MessageUnpacker unpacker) throws IOException {
      ImmutableValue v = unpacker.unpackValue();
      if(v.isIntegerValue())
        return (float) v.asIntegerValue().toInt();
      return v.asFloatValue().toFloat();
    }
    
    private void handleSingleMessage(ReceivedMessageType msgType, MessageUnpacker unpacker) throws IOException {
     // println(msgType);
      switch(msgType) {
        case NEW_PLAYER: {
          assert unpacker.unpackArrayHeader() == 2;
          int playerId = unpacker.unpackInt();
          String playerName = unpacker.unpackString(); 
          mr.receivedNewPlayer(playerId, playerName);
          break;
        }
        
        case PLAYER_MOVE: {
          assert unpacker.unpackArrayHeader() == 5;
          int playerId = unpacker.unpackInt();
          float x = unpackFloat(unpacker);
          float y = unpackFloat(unpacker);         
          short flags = unpacker.unpackShort();
          int gunId = unpacker.unpackInt();
          
          boolean crouch = (flags & (1 << 0)) != 0;
          boolean run = (flags & (1 << 1)) != 0;
   
          mr.receivedMovePlayer(playerId, x, y, crouch, run, gunId);
          break;
        }
        
        case SHOT: { 
          final int size = unpacker.unpackArrayHeader();
          int playerId = unpacker.unpackInt();
          
          ArrayList<Point> receivedShots = new ArrayList<Point>();
          
          for(int i = 1; i < size; i += 2) {         
             float shotx = unpackFloat(unpacker);
             float shoty = unpackFloat(unpacker);
                
             receivedShots.add(new Point(shotx, shoty));           
          }
          mr.receivedShot(playerId, receivedShots);
          break;
        }
        
        case SET_HP: {
          int size = unpacker.unpackArrayHeader();
          
          if(size == 3) {
            int playerId = unpacker.unpackInt();
            int hp = unpacker.unpackInt();
            int shooterId = unpacker.unpackInt();
            
            mr.receivedSetHp(playerId, hp, shooterId);
          } else if(size == 2) {
            int playerId = unpacker.unpackInt();
            int hp = unpacker.unpackInt();
            
            mr.receivedSetHp(playerId, hp);
          } else {
            throw new RuntimeException("Unexpected SET_HP array length"); 
          }
          break;
        }
        
        case DISCONNECT: {
          assert unpacker.unpackArrayHeader() == 1;
          int playerId = unpacker.unpackInt();
          
          mr.receivedDisconnect(playerId);
          break;
        }
        
        case CHAT: {
          assert unpacker.unpackArrayHeader() == 1;
          String message = unpacker.unpackString();
          
          mr.receivedChatMessage(message);
          break;
        }   
        
        case TEAM: { 
          assert unpacker.unpackArrayHeader() == 2;
          int playerId = unpacker.unpackInt();
          int teamColor = unpacker.unpackInt();
          
          mr.receivedColor(playerId, teamColor);
          break;
        }
        
        case STATS: {
          ArrayList<ReceivedPlayerStats> stats = new ArrayList<ReceivedPlayerStats>();
          
          int len = unpacker.unpackArrayHeader();
          for(int i = 0; i < len; i++) {
            ReceivedPlayerStats playerStats = new ReceivedPlayerStats();
            stats.add(playerStats);
            
            assert unpacker.unpackArrayHeader() == 3;
            playerStats.playerId = unpacker.unpackInt();
            playerStats.kills = unpacker.unpackInt();
            playerStats.deaths = unpacker.unpackInt();
          }
          
          mr.receivedStats(stats);
          break; 
        }
      }
    }
}
