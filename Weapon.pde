
class Weapon {
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
        }break;
        case "mac":
        {
           damage = 1;
           fire_rate = 80;
           accuracy = 0.4;
           max_ammo = 50;
           multiple = 1;
           weight = 0.1;
        }break;
        case "shotgun":
        {
           damage = 2;
           fire_rate = 800;
           accuracy = 0.25;
           max_ammo = 8;
           multiple = 5;
           weight = 0.5;
        }break;
        case "AK47":
        {
           damage = 3;
           fire_rate = 160;
           accuracy = 0.6;
           max_ammo = 32;
           multiple = 1;
           weight = 0.4;
        }break;
        case "rifle":
        {
           damage = 10;
           fire_rate = 1000;
           accuracy = 1;
           max_ammo = 30;
           multiple = 1;
           weight = 0.6;
        }break;  
        case "super90":
        {
           damage = 1;
           fire_rate = 400;
           accuracy = 0.25;
           max_ammo = 12;
           multiple = 4;
           weight = 0.5;
        }break;
        case "M4":
        {
           damage = 2;
           fire_rate = 170;
           accuracy = 0.9;
           max_ammo = 30;
           multiple = 1;
           weight = 0.4;
        }break;
        case "PSG-1":
        {
           damage = 5;
           fire_rate = 400;
           accuracy = 1;
           max_ammo = 30;
           multiple = 1;
           weight = 0.7;
        }break;
        case "P90":
        {
           damage = 1;
           fire_rate = 100;
           accuracy = 0.5;
           max_ammo = 50;
           multiple = 1;
           weight = 0.1;
        }break;
        case "M14":
        {
           damage = 3;
           fire_rate = 400;
           accuracy = 0.8;
           max_ammo = 25;
           multiple = 1;
           weight = 0.4;
        }break;
        case "mp5":
        {
           damage = 1;
           fire_rate = 90;
           accuracy = 0.5;
           max_ammo = 30;
           multiple = 1;
           weight = 0.1;
        }break;
        case "M61Vulcan":
        {
           damage = 1;
           fire_rate = 40;
           accuracy = 0.3;
           max_ammo = 150;
           multiple = 1;
           weight = 0.9;
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
        }break;
     }
     before = millis() + 400 - fire_rate;
     playsound("overload.wav");
     ammo = max_ammo;
 }
 
 void give_ammo() {
   ammo += int(max_ammo/2);
   if(ammo > max_ammo)
     ammo = max_ammo;
 }
  
}
