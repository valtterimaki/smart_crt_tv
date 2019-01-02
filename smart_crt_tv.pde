import org.gicentre.utils.move.Ease;

// this will be the switch for the xy mode in the future
public boolean xy_draw_mode = false;

// Flash object
ObjFlash objFlash1;

// Weather object init
Weather weather;

// Fonts
PFont source_code_thin;

void setup() {
  //fullScreen(P2D);
  size(640, 480, P2D);
  frameRate(50);

  // Creating always-on flash object
  objFlash1 = new ObjFlash(0.9, 0.9, 50);

  // Weather object
  weather = new Weather();

  // Set font
  source_code_thin = createFont("SourceCodePro-ExtraLight.ttf", 128);

}

void draw() {
  background(0);

  objFlash1.update();
  objFlash1.display();

  fill(255);
  textFont(source_code_thin);
  textSize(20);

  text(weather.getWeatherCondition(), 16, 60);
  text(weather.getSunrise(), 16, 80);
  text(weather.getSunset(), 16, 100);
  text(weather.getPressure(), 16, 120);
  text(weather.getHumidity(), 16, 140);
  text(weather.getTemperatureMin(), 16, 180);
  text(weather.getTemperatureMax(), 16, 200);

  textSize(128);
  text(weather.getTemperature() + "°c", 16, 300);

}

void mouseReleased() {

}
