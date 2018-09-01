import static java.awt.event.KeyEvent.CHAR_UNDEFINED;
import static java.awt.event.KeyEvent.VK_ENTER;

interface TypedChatMessageReceiver {
  void playerTypedChatMessage(String msg); 
}

class ChatMessage {
  private TypedChatMessageReceiver mr;
  private String message = "";
  
  ChatMessage(TypedChatMessageReceiver mr) {
    this.mr = mr;
  }
  
  public String getTypingMessage() {
    return "> " + message; 
  }

  public void keys_typed(processing.event.KeyEvent ev) {
    char ch = ev.getKey();
   
    if(message.length() >= 250)
      return;
    
    if(!isPrintableChar(ch))
      return;
    
    message += ch;
  }
  
  public void backspace() {
    if(message.length() == 0)
      return;
      
    message = message.substring(0, message.length() - 1);    
  }
  
  public void finalise() {
    mr.playerTypedChatMessage(message); 
  }
    
  // Source: https://stackoverflow.com/a/418560/3105260
  private boolean isPrintableChar(char c) {
    Character.UnicodeBlock block = Character.UnicodeBlock.of(c);
    return (!Character.isISOControl(c)) &&
            c != CHAR_UNDEFINED &&
            block != null &&
            block != Character.UnicodeBlock.SPECIALS;
  }
}
