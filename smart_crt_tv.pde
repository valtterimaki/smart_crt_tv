import org.gicentre.utils.move.Ease;

// this will be the switch for the xy mode in the future
public boolean xy_draw_mode = false;
// program number
public int program_number = 0;

// counter variable that can be set inside programs
int counterstart = millis();
public int counter = 0;

// variable to check if program ust started
public boolean program_started = true;

// Flash object
ObjFlash objFlash1;
// Weather icon
ObjSvg objWeathericon;
// Weather object init
Weather weather;
// Init fonts
PFont source_code_thin;
PFont source_code_light;

// SVG TEST
public String xml_test = "img/sunny.svg";


void setup() {
  //fullScreen(P2D);
  size(640, 480, P2D);
  frameRate(50);

  // Creating always-on flash object
  objFlash1 = new ObjFlash(0.9, 0.9, 50);

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

    // set of actions that happen in the start of the program
    if (program_started == true) {
      println("BUM");
      program_started = false;
    }

    objFlash1.update();
    objFlash1.display();
  }

  // 1 is WEATHER
  if (program_number == 1) {

    /* TODO remember to add weather update interval */

    // set of actions that happen in the start of the program
    if (program_started == true) {
      println("BUM");
      objWeathericon = new ObjSvg(xml_test, 300, 100, 6, 2, 1833);
      program_started = false;
    }

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

    objWeathericon.update();
    objWeathericon.display();

    // end program after 5 seconds
    if (counter == 5) {
      objWeathericon = null;
      counter = 0;
      program_number = 0;
      program_started = true;
    }

  }

}

void mouseReleased() {

}
