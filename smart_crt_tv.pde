
/* LIBRARIES */

import org.gicentre.utils.move.Ease;
import java.util.Collections;
import java.util.Arrays;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Date;


/* VARIABLES */

// program number
public int program_number = 0;
public int[] program_cycle = new int[10];
public int program_cycle_counter = 0;

// main counter variable that can be set inside programs
public int counterstart = millis();
public int counter = 0;

// variable to check if program just started
public boolean program_started = true;


/* OBJECTS */

// Initialize particle systems / other graphics object collections
SwimmerSystem swimmer_system;
SnowSystem snow_system;
RainSystem rain_system;
PseudoCodeOne pseudo_code_one;
WaveSystem wave_system;
CloudSystem cloud_system;
SunSystem sun_system;
//NewSystem new_system;

// Flash object
ObjFlash objFlash1;

// create variable for weather icon path
public String weather_icon;
// Weather icon object init
ObjSvg objWeathericon;

// Weather object for handling weather stuff
Weather weather;
WeatherNew weather_new;


/* FONTS */

PFont source_code_thin;
PFont source_code_light;
PFont tesserae;
PFont lastwaerk_thin, lastwaerk_regular;
PFont bungee;
PFont aspace_thin, aspace_light, aspace_regular;
PFont rajdhani_light;


// SETUP //////////////////////////////////////////////////////////////////////


void setup() {
  fullScreen(P2D);  //use this in the actual build in the tv
  //size(640, 480, P2D);
  smooth(1);
  frameRate(50);

  // Creating always-on flash object
  objFlash1 = new ObjFlash(0.9, 0.9, 50);

  // Weather object
  weather = new Weather();
  weather_new = new WeatherNew();

  // Create particle systems
  swimmer_system = new SwimmerSystem();
  snow_system = new SnowSystem();
  rain_system = new RainSystem();
  pseudo_code_one = new PseudoCodeOne();
  wave_system = new WaveSystem(40,100);
  cloud_system = new CloudSystem();
  sun_system = new SunSystem();
  //new_system = new NewSystem();

  // Set fonts
  source_code_thin = createFont("SourceCodePro-ExtraLight.ttf", 128);
  source_code_light = createFont("SourceCodePro-Light.ttf", 24);
  tesserae = createFont("Tesserae-4x4Extended.otf", 20);
  lastwaerk_thin = createFont("lastwaerk-thin.ttf", 128);
  lastwaerk_regular = createFont("lastwaerk-light.ttf", 128);
  bungee = createFont("bungee-hairline.otf", 128);
  aspace_thin = createFont("a-space-thin.otf", 128);
  aspace_light = createFont("a-space-light.otf", 128);
  aspace_regular = createFont("a-space-regular.otf", 128);
  rajdhani_light = createFont("rajdhani-light.ttf", 128);

}


// DRAW ///////////////////////////////////////////////////////////////////////


void draw() {

  // main counter to count seconds
  if ( (millis() - counterstart) > 1000 ) {
    counter++;
    counterstart = millis();
  }

  // clear screen
  background(0);


  /* "PROGRAMS" */


  // 0 is FLASH
  // This happens between every other programs
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
      objWeathericon = new ObjSvg(weather_icon, 330, 100, 3, 0.6, 1833);
      program_started = false;
    }

    int leftmargin = 96;
    int topmargin = 220;
    int lineheight = 26;

    fill(255);

    textFont(source_code_light);
    textSize(24);
    textAlign(LEFT);


    text("Sää, " + weather.getWeatherCondition(), leftmargin, topmargin + lineheight * 1);
    text(round(weather.getTemperatureMin()) + " - " + round(weather.getTemperatureMax()) + " °c", leftmargin, topmargin + lineheight * 2);
    text("Kosteus " + weather.getHumidity() + " %", leftmargin, topmargin + lineheight * 4);
    //text("Paine " + weather.getPressure() + " hPa", leftmargin, topmargin + lineheight * 5);
    text("Päivänvaloa " + minutes_to_time(get_sun_in_minutes("rise"))+ " - " + minutes_to_time(get_sun_in_minutes("set")), leftmargin, topmargin + lineheight * 6);
    //text("Aurinko nousee klo " + minutes_to_time(get_sun_in_minutes("rise")), leftmargin, topmargin + lineheight * 7);
    //text("Aurinko laskee klo " + minutes_to_time(get_sun_in_minutes("set")), leftmargin, topmargin + lineheight * 8);

    textFont(aspace_thin);
    textSize(96);
    text(round(weather.getTemperature()) + "°c", leftmargin-10, 180);


    objWeathericon.update();
    objWeathericon.display();

    // static distortion effect
    fxStatic();

    // end program after 5 seconds
    if (counter >= 14) {
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
    if (counter >= 10) {
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

      // run the system for some loops to prevent the initialization glitches
      for (int i = 0; i < 50; ++i) {
        rain_system.run();
        background(0); // draw black after this to start from black
      }
    }

    // end program after 8 seconds
    if (counter >= 10) {
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
    if (counter >= 10) {
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
    if (counter >= 10) {
     counter = 0;
     program_number = 0;
      program_started = true;
    }

    // this is exected here so that the particle system can detect the program change and remove the particles
    wave_system.run();

  }


  // 8 is CLOUDS
  if (program_number == 8) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      cloud_system.setup();
      program_started = false;
    }

    // end program after 8 seconds
    if (counter >= 14) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }

   // this is exected here so that the particle system can detect the program change and remove the particles
   cloud_system.run();
  }


  // 9 is Sun
  if (program_number == 9) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      sun_system.setup();
      program_started = false;
    }

    // end program after 8 seconds
    if (counter == 10) {
     counter = 0;
     program_number = 0;
      program_started = true;
    }

     // this is exected here so that the particle system can detect the program change and remove the particles
     sun_system.run();
  }

  // 10 is FORECAST
  if (program_number == 10) {

    /* TODO remember to add weather update interval */

    // set of actions that happen in the start of the program
    if (program_started == true) {
      weather_new.anim_phase = 0;
      program_started = false;
    }

    /////// draw here
    weather_new.update();
    weather_new.drawForecast();

    // end program after 5 seconds
    if (counter >= 14) {
      objWeathericon = null;
      counter = 0;
      program_number = 0;
      program_started = true;
    }
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
