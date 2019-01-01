import org.gicentre.utils.move.Ease;

// this will be the switch for the xy mode in the future 
public boolean xy_draw_mode = false;

// Flash object
ObjFlash objFlash1;

Weather weather;

void setup() {
  //fullScreen(P2D);
  size(640, 480, P2D);
  frameRate(50);

  // Creating always-on flash object
  objFlash1 = new ObjFlash(0.9, 0.9, 50); 

  // Weather api
  weather = new Weather();

}

void draw() {
  background(0);

  objFlash1.update();
  objFlash1.display();

  fill(255);
  textSize(18);
  text(weather.getCityName(), 16, 20);
  text(weather.getCountryName(), 16, 40);
  text(weather.getWeatherCondition(), 16, 60);
  text(weather.getSunrise(), 16, 80);
  text(weather.getSunset(), 16, 100);
  text(weather.getPressure(), 16, 120);
  text(weather.getHumidity(), 16, 140);
  text(weather.getTemperature(), 16, 160);
  text(weather.getTemperatureMin(), 16, 180);
  text(weather.getTemperatureMax(), 16, 200);
}

void mouseReleased() {

}
