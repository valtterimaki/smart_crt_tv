
/* LIBRARIES */

import org.gicentre.utils.move.Ease;
import java.util.Collections;
import java.util.Arrays;
import java.net.HttpURLConnection;
import javax.net.ssl.HttpsURLConnection;
import java.net.URL;
import java.util.Date;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import processing.video.*;


/* GLOBAL VARIABLES */

// Program number
public int program_number = 0;
public int[] program_cycle = new int[10];
public int program_cycle_counter = 0;

// Main counter variable that can be set inside programs
public int counterstart = millis();
public int counter = 0;

// Variable to check if program just started
public boolean program_started = true;

// Animator helpers
public float anim_1_start, anim_1_duration, anim_1_phase = 0;

// Variables for setting overscan safe areas
public int os_left = 48;
public int os_right = 28;
public int os_top = 10;
public int os_bottom = 8;
public int os_width = width - os_left - os_right;
public int os_height = height - os_top - os_bottom;

// 3d objects
// NOTE! CANNOT DO THIS WITHOUT BETTER GEAR (PI4)
//PShape obj_iss;

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

// Create variable for weather icon path
public String weather_icon;
// weather icon object init
ObjSvg objWeathericon;

// Weather object for handling weather stuff
Weather weather;
ForecastFmi forecast_fmi;
ForecastYr  forecast_yr;
ElectricityUse electricity_use;

// ISS tracker class
IssTracker iss;

// noise shader
PShader noise2;
PImage tex = createImage(1024, 576, RGB);

// videos
public Movie src_mov;
ScanVideo scanvideo;


/* FONTS */

PFont source_code_thin;
PFont source_code_light;
PFont tesserae;
PFont lastwaerk_thin, lastwaerk_light, lastwaerk_regular;
PFont bungee_thin, bungee_regular;
PFont aspace_thin, aspace_light, aspace_regular;
PFont rajdhani_light;
PFont mplus_thin, mplus_regular;
PFont robotomono_light, robotomono_regular, robotomono_semibold;



// SETUP //////////////////////////////////////////////////////////////////////


void setup() {

  fullScreen(P3D);        // use this in the actual build in the tv
  //size(720, 576, P3D);  // use this for development
  smooth(1);

  // Flash object after each program
  objFlash1 = new ObjFlash();

  // Weather object
  weather = new Weather();
  forecast_fmi = new ForecastFmi();
  forecast_yr = new ForecastYr();
  electricity_use = new ElectricityUse();

  // Create particle systems
  swimmer_system = new SwimmerSystem();
  snow_system = new SnowSystem();
  rain_system = new RainSystem();
  pseudo_code_one = new PseudoCodeOne();
  wave_system = new WaveSystem(40,130);
  cloud_system = new CloudSystem();
  sun_system = new SunSystem();
  //new_system = new NewSystem();

  //ISS tracker
  iss = new IssTracker();

  // video
  src_mov = new Movie(this, "iss2.mp4");
  src_mov.loop();
  scanvideo = new ScanVideo(0, 0, 5, 1000, 1);

  // Set fonts
  source_code_thin = createFont("SourceCodePro-ExtraLight.ttf", 128);
  source_code_light = createFont("SourceCodePro-Light.ttf", 24);
  tesserae = createFont("Tesserae-4x4Extended.otf", 20);
  lastwaerk_thin = createFont("lastwaerk-thin.ttf", 128);
  lastwaerk_light = createFont("lastwaerk-light.ttf", 128);
  lastwaerk_regular = createFont("lastwaerk-regular.ttf", 128);
  bungee_thin = createFont("bungee-hairline.otf", 128);
  bungee_regular = createFont("bungee-regularedit.otf", 25);
  aspace_thin = createFont("a-space-thin.otf", 128);
  aspace_light = createFont("a-space-light.otf", 128);
  aspace_regular = createFont("a-space-regular.otf", 128);
  rajdhani_light = createFont("rajdhani-light.ttf", 128);
  mplus_thin = createFont("MPLUSRounded1c-Thin.ttf", 128);
  mplus_regular = createFont("MPLUSRounded1c-Regular.ttf", 128);
  robotomono_regular = createFont("RobotoMono-Regular.ttf", 128);
  robotomono_light = createFont("RobotoMono-Light.ttf", 128);
  robotomono_semibold = createFont("RobotoMono-SemiBold.ttf", 128);

  // noise shader setup
  textureWrap(REPEAT);
  noise2 = loadShader("noise2.glsl");
  noise2.set("resolution", float(width), float(height));

  // noise shader default settings
  noise2.set("amount", 0);

  //obj_iss = loadShape("3d/iss.obj");
  ortho();

  frameRate(50);
}


// DRAW ///////////////////////////////////////////////////////////////////////


void draw() {

  // main counter to count seconds
  if ( (millis() - counterstart) > 1000 ) {
    counter++;
    counterstart = millis();
  }


  // clear screen
  if ( program_number != 0 ){
    background(0);
  }


  /* "PROGRAMS" */


  // 0 is FLASH
  // This happens between every other programs
  if (program_number == 0) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      tex = get();
      program_started = false;
    }

    objFlash1.update();
    //objFlash1.display();

  }

  resetShader();


  // 1 is WEATHER
  if (program_number == 1) {

    /* TODO remember to add weather update interval */

    // set of actions that happen in the start of the program
    if (program_started == true) {
      // icon set
      weather_icon = "img/" + weather.getWeatherConditionIcon() + ".svg";
      objWeathericon = new ObjSvg(weather_icon, 330, 40, 3, 0.6, 1833);
      program_started = false;
    }

    int leftmargin = 96;
    int topmargin = 400;
    int lineheight = 28;

    fill(255);
    textAlign(LEFT);

    textFont(aspace_thin);
    textSize(96);
    text(round(weather.getTemperature()) + "°c", leftmargin-10, 180);

    textFont(source_code_light);
    textSize(25);
    text("Max " + round(weather.getTemperatureMax()) + "°c", leftmargin, 220);
    text("Min " + round(weather.getTemperatureMin()) + "°c", leftmargin, 245);

    textFont(source_code_light);
    textSize(25);
    text("Olosuhteet, " + weather.getWeatherCondition(), leftmargin, topmargin + lineheight * 1);
    text("Kosteus " + weather.getHumidity() + " %", leftmargin, topmargin + lineheight * 2);
    //text("Paine " + weather.getPressure() + " hPa", leftmargin, topmargin + lineheight * 5);
    text("Päivänvaloa " + minutes_to_time(get_sun_in_minutes("rise"))+ " - " + minutes_to_time(get_sun_in_minutes("set")), leftmargin, topmargin + lineheight * 3);
    //text("Aurinko nousee klo " + minutes_to_time(get_sun_in_minutes("rise")), leftmargin, topmargin + lineheight * 7);
    //text("Aurinko laskee klo " + minutes_to_time(get_sun_in_minutes("set")), leftmargin, topmargin + lineheight * 8);


    objWeathericon.update();
    objWeathericon.display();

    // end program after 14 seconds
    if (counter >= 14) {
      objWeathericon = null;
      counter = 0;
      program_number = 0;
      program_started = true;
    }
  }


  // 2 is FORECAST
  if (program_number == 2) {

    /* TODO remember to add weather update interval */

    // set of actions that happen in the start of the program
    if (program_started == true) {
      forecast_fmi.update();
      forecast_fmi.anim_phase = 0;
      program_started = false;
    }

    // draw here
    forecast_fmi.drawForecast();

    // end program after 14 seconds
    if (counter >= 14) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }
  }


  // 3 is CONDITION
  if (program_number == 3) {

    if (str(weather.getWeatherConditionID()).charAt(0) == '5' || str(weather.getWeatherConditionID()).charAt(0) == '3' || str(weather.getWeatherConditionID()).charAt(0) == '2') {
      //println("drizzle or rain or thunder");
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
      // this is exected here so that the particle system can detect the program change and remove the particles
      rain_system.run();
    }

    if (str(weather.getWeatherConditionID()).charAt(0) == '6') {
      //println("snow");
      // set of actions that happen in the start of the program
      if (program_started == true) {
        for (int i = 0; i < 100; ++i) {
          snow_system.addParticle();
        }
        program_started = false;
      }
      // this is exected here so that the particle system can detect the program change and remove the particles
      snow_system.run();
    }

    /*if (str(weather.getWeatherConditionID()).charAt(0) == '7') {
      println("atmo");
    }*/

    if (str(weather.getWeatherConditionID()).equals("800")) {
      //println("clear");
      // set of actions that happen in the start of the program
      if (program_started == true) {
        sun_system.setup();
        program_started = false;
      }
      // this is exected here so that the particle system can detect the program change and remove the particles
      sun_system.run();
    }

    if ((str(weather.getWeatherConditionID()).charAt(0) == '8' && str(weather.getWeatherConditionID()).charAt(2) != '0') || str(weather.getWeatherConditionID()).charAt(0) == '7') {
      //println("clouds or foggy");
      // set of actions that happen in the start of the program
      if (program_started == true) {
        cloud_system.setup();
        program_started = false;
      }
     // this is exected here so that the particle system can detect the program change and remove the particles
     cloud_system.run();
    }

    // check counter and end program if 10 seconds have passed
    if (counter >= 10) {
      cloud_system.reset();
      counter = 0;
      program_number = 0;
      program_started = true;
    }

  }


  // 4 is SUNRISE
  if (program_number == 4) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      program_started = false;
    }

    // end program after 10 seconds
    if (counter >= 10) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }

    // draw and update sun diagram
    draw_sun_diagram();

  }


  // 5 is PSEUDOCODE
  if (program_number == 5) {

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


  // 6 is WAVES
  if (program_number == 6) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      wave_system.setup();
      program_started = false;
    }

    // end program after 10 seconds
    if (counter >= 14) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }

    // this is exected here so that the particle system can detect the program change and remove the particles
    wave_system.run();


  }


  // 7 is SWIMMER
  if (program_number == 7) {

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


  // 8 is ISS
  if (program_number == 8) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      iss.update();
      iss.anim_phase = 0;
      forecast_yr.findIssMatch();
      scanvideo.updatePos(300, 100);
      program_started = false;
    }

    // draw here
    if (is_movie_finished(src_mov) == true) {
      src_mov.jump(0);
    }
    iss.run();

    // end program after 14 seconds
    if (counter >= 14) {
      objWeathericon = null;
      counter = 0;
      program_number = 0;
      program_started = true;
    }
  }

  // 9 is CLOCK
  if (program_number == 9) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      program_started = false;
    }

    // draw here

    int radius = min(width, height) / 5;
    float secondsRadius = radius * 0.9;
    float minutesRadius = radius * 0.85;
    float hoursRadius = radius * 0.6;
    float clockDiameter = radius * 2;

    int cx = 200;
    int cy = height / 2;

    // Angles for sin() and cos() start at 3 o'clock;
    // subtract HALF_PI to make them start at the top
    float s = map(second(), 0, 60, 0, TWO_PI) - HALF_PI;
    float m = map(minute() + norm(second(), 0, 60), 0, 60, 0, TWO_PI) - HALF_PI;
    float h = map(hour() + norm(minute(), 0, 60), 0, 24, 0, TWO_PI * 2) - HALF_PI;

    // Draw the hands of the clock
    stroke(255,0,0);
    strokeWeight(2);
    line(cx, cy, cx + cos(s) * secondsRadius, cy + sin(s) * secondsRadius);
    stroke(255);
    strokeWeight(2);
    line(cx, cy, cx + cos(m) * minutesRadius, cy + sin(m) * minutesRadius);
    strokeWeight(4);
    line(cx, cy, cx + cos(h) * hoursRadius, cy + sin(h) * hoursRadius);

    // Draw the minute ticks
    strokeWeight(4);
    beginShape(POINTS);
    for (int a = 0; a < 360; a+=30) {
      float angle = radians(a);
      float x = cx + cos(angle) * radius;
      float y = cy + sin(angle) * radius;
      vertex(x, y);
    }
    endShape();

    fill(255);
    textAlign(LEFT);
    textFont(aspace_light);
    textSize(40);
    text(nf(hour(), 2) + " : " + nf(minute(), 2) + " : " + nf(second(), 2), cx + 180, cy+10);

    // end program after 9 seconds
    if (counter >= 9) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }
  }

  // 10 is ELECTRICITY USE
  if (program_number == 10) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      electricity_use.update();
      electricity_use.anim_phase = 0;
      program_started = false;
    }

    // draw here
    electricity_use.drawElect();

    // end program after 20 seconds
    if (counter >= 20) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }
  }

   // 11 is GLITCH VIDEO
   /*
  if (program_number == 11) {

    // set of actions that happen in the start of the program
    if (program_started == true) {
      program_started = false;
    }

    // draw here


    // end program after 20 seconds
    if (counter >= 20) {
      counter = 0;
      program_number = 0;
      program_started = true;
    }
  }
  */

  // Draw overscan test area
  // Use this to check if everything fits the screen
  //drawOverscanArea(1);


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
