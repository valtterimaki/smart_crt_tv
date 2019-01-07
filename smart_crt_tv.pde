import org.gicentre.utils.move.Ease;

// this will be the switch for the xy mode in the future
public boolean xy_draw_mode = false;
// program number
public int program_number = 0;

// counter variable that can be set inside programs
int counterstart = millis();
public int counter = 0;

// Flash object
ObjFlash objFlash1;
// Weather object init
Weather weather;
// Init fonts
PFont source_code_thin;
PFont source_code_light;

// SVG TEST
public String xml_test = "img/sunny.svg";
ObjSvg objSvg1;

void setup() {
  //fullScreen(P2D);
  size(640, 480, P2D);
  frameRate(50);

  // Creating always-on flash object
  objFlash1 = new ObjFlash(0.9, 0.9, 50);

  // Svg test (this needs to have an array for multiple images)
  objSvg1 = new ObjSvg(xml_test, 300, 100, 2);

  // Weather object
  weather = new Weather();

  // Set fonts
  source_code_thin = createFont("SourceCodePro-ExtraLight.ttf", 128);
  source_code_light = createFont("SourceCodePro-Light.ttf", 20);

}

void draw() {

  // count milliseconds
  if( (millis() - counterstart) > 1000 ){
    counter++;
    counterstart = millis();
  }

  // clear screen
  background(0);

  // 0 is FLASH
  if (program_number == 0) {
    objFlash1.update();
    objFlash1.display();
  }

  // 1 is WEATHER
  if (program_number == 1) {

    /* TODO remember to add update interval */

    fill(255);

    textFont(source_code_light);
    textSize(20);
    text(weather.getWeatherCondition(), 16, 60);
    text(weather.getSunrise(), 16, 80);
    text(weather.getSunset(), 16, 100);
    text(weather.getPressure(), 16, 120);
    text(weather.getHumidity(), 16, 140);
    text(weather.getTemperatureMin(), 16, 180);
    text(weather.getTemperatureMax(), 16, 200);

    textFont(source_code_thin);
    textSize(128);
    text(weather.getTemperature() + "°c", 16, 300);

    // SVG TEST
    objSvg1.display();
    println(frameRate);

    if (counter == 5) {
      counter = 0;
      program_number = 0;
    }

  }

}

void mouseReleased() {

}
