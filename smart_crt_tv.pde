import org.gicentre.utils.move.Ease;
import java.util.Collections;
import java.util.Arrays;

// this will be the switch for the xy mode in the future
public boolean xy_draw_mode = false;
// program number
public int program_number = 0;
public int[] program_cycle = new int[7];
public int program_cycle_counter = 0;

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
PFont tesserae;

// Initialize particle systems
SwimmerSystem swimmer_system;
SnowSystem snow_system;
RainSystem rain_system;
PseudoCodeOne pseudo_code_one;
WaveSystem wave_system;
//NewSystem new_system;


void setup() {
  //fullScreen(P2D);
  size(640, 480, P2D);
  smooth(1);
  frameRate(50);

  // Creating always-on flash object
  objFlash1 = new ObjFlash(0.9, 0.9, 50);

  // Weather object
  weather = new Weather();

  // Create particle systems
  swimmer_system = new SwimmerSystem();
  snow_system = new SnowSystem();
  rain_system = new RainSystem();
  pseudo_code_one = new PseudoCodeOne();
  wave_system = new WaveSystem(40,100);
  //new_system = new NewSystem();

  // Set fonts
  source_code_thin = createFont("SourceCodePro-ExtraLight.ttf", 128);
  source_code_light = createFont("SourceCodePro-Light.ttf", 20);
  tesserae = createFont("Tesserae-4x4Extended.otf", 20);
}

void draw() {

  // count milliseconds
  if ( (millis() - counterstart) > 1000 ) {
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
    text(weather.getWeatherCondition(), 16, 320);
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
    if (counter >= 5) {
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

    // end program after 8 seconds
    if (counter >= 8) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }

    // this is exected here so that the particle system can detect the program change and remove the particles
    swimmer_system.run();
  }

  // 3 is SNOW
  if (program_number == 3) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      for (int i = 0; i < 100; ++i) {
        snow_system.addParticle();
      }
      program_started = false;
    }

    // end program after 8 seconds
    if (counter >= 8) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }

    // this is exected here so that the particle system can detect the program change and remove the particles
    snow_system.run();
  }


  // 4 is RAIN
  if (program_number == 4) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      for (int i = 0; i < 400; ++i) {
        rain_system.addParticle();
      }
      program_started = false;
    }

    // end program after 8 seconds
    if (counter >= 8) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }

    // this is exected here so that the particle system can detect the program change and remove the particles
    rain_system.run();
  }


  // 5 is SUNRISE
  if (program_number == 5) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      program_started = false;
    }

    // end program after 8 seconds
    if (counter >= 8) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }

    // draw and update sun diagram
    draw_sun_diagram();
  }


  // 6 is PSEUDOCODE
  if (program_number == 6) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      pseudo_code_one.setup();
      program_started = false;
    }

    // end program after 8 seconds
    if (counter >= 8) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }

    pseudo_code_one.update();
    pseudo_code_one.draw();
  }


  // 7 is WAVES
  if (program_number == 7) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      wave_system.setup();
      program_started = false;
    }

    // end program after 8 seconds
    if (counter >= 8) {
     counter = 0;
     program_number = 0;
      program_started = true;
    }

    // this is exected here so that the particle system can detect the program change and remove the particles
    wave_system.run();

  }


  // TEMPLATE FOR A NEW SYSTEM

  /*

  // 4 is NEW
  if (program_number == 3) {

  // set of actions that happen in the start of the program
  if (program_started == true) {
    for (int i = 0; i < 20; ++i) {
      new_system.addParticle();
    }
    program_started = false;
  }

  // end program after 8 seconds
  if (counter == 8) {
   counter = 0;
   program_number = 0;
    program_started = true;
  }

   // this is exected here so that the particle system can detect the program change and remove the particles
   new_system.run();

   }

   */

}
