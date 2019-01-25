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

// create variable for weather icon path
public String weather_icon;

// Flash object
ObjFlash objFlash1;
// Weather icon
ObjSvg objWeathericon;
// Weather object init
Weather weather;
// Init fonts
PFont source_code_thin;
PFont source_code_light;
// Swimmer particle system test object init
SwimmerSystem swimmer_system;


void setup() {
  //fullScreen(P2D);
  size(640, 480, P2D);
  frameRate(50);

  // Creating always-on flash object
  objFlash1 = new ObjFlash(0.9, 0.9, 50);

  // Weather object
  weather = new Weather();

  // Swimmer system
   swimmer_system = new SwimmerSystem();

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
      // icon set
      weather_icon = "img/" + weather.getWeatherConditionIcon() + ".svg";
      objWeathericon = new ObjSvg(weather_icon, 300, 100, 3, 0.6, 1833);
      program_started = false;
    }

    fill(255);

    textFont(source_code_light);
    textSize(20);
    text(weather.getWeatherCondition(), 16, 260);
    text(weather.getSunrise(), 16, 280);
    text(weather.getSunset(), 16, 300);
    text(weather.getPressure(), 16, 320);
    text(weather.getHumidity(), 16, 340);
    text(weather.getTemperatureMin(), 16, 380);
    text(weather.getTemperatureMax(), 16, 400);

    textFont(source_code_thin);
    textSize(96);
    text(weather.getTemperature() + "°c", 16, 250);

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

  // 2 is SWIMMER
  if (program_number == 2) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      for (int i = 0; i < 20; ++i) {
        swimmer_system.addParticle();
      }
      program_started = false;
    }

    // end program after 5 seconds
    if (counter == 8) {
      counter = 0;
      program_number = 0;
      program_started = true;
      // maybe set the particle system to nulls?
    }

    swimmer_system.run();

  }

}


