import processing.net.*;

import org.msgpack.core.MessagePack;
import org.msgpack.core.MessagePacker;
import org.msgpack.core.MessageUnpacker;
import org.msgpack.value.*;

interface MessageReceiver {
   void receivedNewPlayer(int playerId, String name); 
   void receivedMovePlayer(int playerId, float x, float y, boolean crouch, boolean run);
}

private enum ReceivedMessageType {
  NEW_PLAYER,
  PLAYER_MOVE,
}

class Network {
    private final int SEND_SET_NICKNAME = 0;
    private final int SEND_MOVE = 1;
    
    private final int BUFFER_LEN = 4096;
  
    private byte[] buffer = new byte[BUFFER_LEN];

    private Client client;
  
    private MessageReceiver mr;
    
    MessageUnpacker unpacker;
    MessagePacker packer;
    
    private ReceivedMessageType[] messageTypeValues = ReceivedMessageType.values();
    
    private void sendNickname(String nickname) throws IOException {
        packer.packArrayHeader(2);
        packer.packInt(SEND_SET_NICKNAME);
        packer.packString(nickname);
        packer.flush();
    }
    
    public void sendMove(float x, float y, boolean crouch, boolean run) {
        if(! client.active()) {
          println("Not connected");
          return;
        }
        
        short flags = 0;
        flags |= ((crouch ? 0 : 1) << 0);
        flags |= ((run ? 0 : 1) << 1);
        
        try {
          packer.packArrayHeader(2);
          packer.packInt(SEND_MOVE);
          packer.packArrayHeader(3);
          packer.packFloat(x);
          packer.packFloat(y);
          packer.packShort(flags);
          packer.flush();
        } catch (IOException ex) {
          println("Failed sending a move packet");
          ex.printStackTrace();
        }
    }
    
    Network(MessageReceiver mr, String nickname) {
        this.mr = mr;
        client = new Client(Area_Of_Fire.this, "35.228.141.175", 7543);
        
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
    
    public void tick() {
      while(client.available() > 0) {
        int read = client.readBytes(buffer);
        try {
          unpackMessage(read);
        } catch(IOException ex) {
          ex.printStackTrace();
        }
      }  
    }
    
    private void unpackMessage(int len) throws IOException {
       
      /*
       print("Got message: ");
       for(int i = 0; i < len; i++) {
          print(buffer[i], " ");
       }
       println("");
       */
       
       MessageUnpacker unpacker = MessagePack.newDefaultUnpacker(buffer, 0, len);
       int mapLength = unpacker.unpackArrayHeader() / 2;
       for(int i = 0; i < mapLength; i++) {
           int messageTypeIndex = unpacker.unpackInt();
           println("recv message type: ", messageTypeIndex);
           
           if(messageTypeIndex < 0 || messageTypeIndex >= messageTypeValues.length) {
              println("Wrong message type: ", messageTypeIndex); 
              return;
           }
           
           ReceivedMessageType msgType = messageTypeValues[messageTypeIndex];
           handleSingleMessage(msgType, unpacker);
       }
    }
    
    private float unpackFloat(MessageUnpacker unpacker) throws IOException {
      ImmutableValue v = unpacker.unpackValue();
      if(v.isIntegerValue())
        return (float) v.asIntegerValue().toInt();
      return v.asFloatValue().toFloat();
    }
    
    private void handleSingleMessage(ReceivedMessageType msgType, MessageUnpacker unpacker) throws IOException {
      println(msgType);
      switch(msgType) {
        case PLAYER_MOVE: {
          if(unpacker.unpackArrayHeader() != 4) {
            println("Unexpected PLAYER_MOVE array length");
            return;
          }
          int playerId = unpacker.unpackInt();
          float x = unpackFloat(unpacker);
          float y = unpackFloat(unpacker);
          short flags = unpacker.unpackShort();
          
          boolean crouch = (flags & (1 << 0)) != 0;
          boolean run = (flags & (1 << 1)) != 0;
          
          mr.receivedMovePlayer(playerId, x, y, crouch, run);
          break;
        }
        case NEW_PLAYER: {
          assert unpacker.unpackArrayHeader() == 2;
          int playerId = unpacker.unpackInt();
          String playerName = unpacker.unpackString();
          mr.receivedNewPlayer(playerId, playerName);
          break;
        }
      }
    }
}
