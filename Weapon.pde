public enum Weapons {
   PISTOL("pistol"),
   MAC("mac"),
   SHOTGUN("shotgun"),
   AK47("AK47"),
   RIFLE("rifle"),
   SUPER90("super90"),
   M4("M4"),
   PSG("PSG-1"),
   P90("P90"),
   M14("M14"),
   MP5("mp5"),
   M61("M61Vulcan");
   
   private Weapons(String name) {
      this.name = name;
   }

   private final String name;

   public String getName() {
      return name;
   }
}


class Weapon {
 int id;
 String name;
 int damage;
 int fire_rate;
 float accuracy;
 int max_ammo;
 int ammo;
 int multiple;
 int before;
 float weight;
 
 Weapon(String n){
     name = n;
     
     
     switch(name) {
        case "pistol":
        {
           damage = 1;
           fire_rate = 300;
           accuracy = 0.7;
           max_ammo = 12;
           multiple = 1;
           weight = 0.05;
           id = 0;
        }break;
        case "mac":
        {
           damage = 1;
           fire_rate = 80;
           accuracy = 0.4;
           max_ammo = 50;
           multiple = 1;
           weight = 0.1;
           id = 1;
        }break;
        case "shotgun":
        {
           damage = 2;
           fire_rate = 800;
           accuracy = 0.25;
           max_ammo = 8;
           multiple = 5;
           weight = 0.5;
           id = 2;
        }break;
        case "AK47":
        {
           damage = 3;
           fire_rate = 160;
           accuracy = 0.6;
           max_ammo = 32;
           multiple = 1;
           weight = 0.4;
           id = 3;
        }break;
        case "rifle":
        {
           damage = 10;
           fire_rate = 1000;
           accuracy = 1;
           max_ammo = 30;
           multiple = 1;
           weight = 0.6;
           id = 4;
        }break;  
        case "super90":
        {
           damage = 1;
           fire_rate = 400;
           accuracy = 0.25;
           max_ammo = 12;
           multiple = 4;
           weight = 0.5;
           id = 5;
        }break;
        case "M4":
        {
           damage = 2;
           fire_rate = 170;
           accuracy = 0.9;
           max_ammo = 30;
           multiple = 1;
           weight = 0.4;
           id = 6;
        }break;
        case "PSG-1":
        {
           damage = 5;
           fire_rate = 400;
           accuracy = 1;
           max_ammo = 30;
           multiple = 1;
           weight = 0.7;
           id = 7;
        }break;
        case "P90":
        {
           damage = 1;
           fire_rate = 100;
           accuracy = 0.5;
           max_ammo = 50;
           multiple = 1;
           weight = 0.1;
           id = 8;
        }break;
        case "M14":
        {
           damage = 3;
           fire_rate = 400;
           accuracy = 0.8;
           max_ammo = 25;
           multiple = 1;
           weight = 0.4;
           id = 9;
        }break;
        case "mp5":
        {
           damage = 1;
           fire_rate = 90;
           accuracy = 0.5;
           max_ammo = 30;
           multiple = 1;
           weight = 0.1;
           id = 10;
        }break;
        case "M61Vulcan":
        {
           damage = 1;
           fire_rate = 40;
           accuracy = 0.3;
           max_ammo = 150;
           multiple = 1;
           weight = 0.9;
           id = 11;
        }break;
        default:
        {
           damage = 1;
           fire_rate = 300;
           accuracy = 0.7;
           max_ammo = 12;
           multiple = 1;
           weight = 0.05;
           name = "pistol";
           id = 0;
        }break;
     }
     before = millis() + 750 - fire_rate;
     playsound("overload.wav");
     ammo = max_ammo;
 }
 
 void give_ammo() {
   ammo += int(max_ammo/2);
   if(ammo > max_ammo)
     ammo = max_ammo;
 }
  
}
