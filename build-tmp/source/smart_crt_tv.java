import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import org.gicentre.utils.move.Ease; 
import java.net.HttpURLConnection; 
import java.net.URL; 
import java.util.Date; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class smart_crt_tv extends PApplet {



// this will be the switch for the xy mode in the future
public boolean xy_draw_mode = false;
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
public String xml_test = "img/cloudy.svg";

public void setup() {
  //fullScreen(P2D);
  
  frameRate(50);

  // Creating always-on flash object
  objFlash1 = new ObjFlash(0.9f, 0.9f, 50);

  // Weather object
  weather = new Weather();

  // Set fonts
  source_code_thin = createFont("SourceCodePro-ExtraLight.ttf", 128);
  source_code_light = createFont("SourceCodePro-Light.ttf", 20);

}

public void draw() {

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
    svgDraw(xml_test);

    if (counter == 5) {
      counter = 0;
      program_number = 0;
    }

  }

}

public void mouseReleased() {

}




/*
Open weather map xml fetcher
By Fossa
 */

class Weather {

  private XML root;
  private boolean reachable;
  ////private String tempUnit;
  private final static String  URL = "http://api.openweathermap.org/data/2.5/weather?q=Turku,fi&appid=252d087e98bfe7e2d4bfa4991e0f4671&units=metric&mode=xml";
  private final static int TIMEOUT = 5000;

  //optional for future
  int citycode = 633679;

  public Weather() {
    ////this.tempUnit = tempUnit;
    reachable = checkConnection();
    println("connection: " + reachable);

    if (reachable) {
      root = loadXML("http://api.openweathermap.org/data/2.5/weather?q=Turku,fi&appid=252d087e98bfe7e2d4bfa4991e0f4671&units=metric&mode=xml");
    } else {
      println("No connection");
    }
  }

  /*
   * General methods
   */
  public boolean checkConnection() {
    try {
      HttpURLConnection connection = (HttpURLConnection) new URL(URL).openConnection();
      connection.setConnectTimeout(TIMEOUT);
      connection.setReadTimeout(TIMEOUT);
      connection.setRequestMethod("HEAD");
      int responseCode = connection.getResponseCode();
      return (200 <= responseCode && responseCode <= 399);
    } catch (IOException exception) {
      return false;
    }
  }

  public void update() {
    reachable = checkConnection();

    if (reachable) {
      root = loadXML("http://api.openweathermap.org/data/2.5/weather?id=2172797&appid=252d087e98bfe7e2d4bfa4991e0f4671&units=metric&mode=xml");
    } else {
      println("No connection");
    }
  }

  public String lastUpdate(){
    Date date = new Date();
    return date.toString();
  }


  /* Current weather & Basics */

  public String getCityName() {
    return root.getChild("city").getString("name");
  }

  public String getCountryName() {
    return root.getChild("city/country").getContent();
  }

  public String getSunrise() {
    return root.getChild("city/sun").getString("rise");
  }

  public String getSunset() {
    return root.getChild("city/sun").getString("set");
  }

  public int getPressure() {
    return root.getChild("pressure").getInt("value"); //unit?
  }

  public int getHumidity() {
    return root.getChild("humidity").getInt("value"); //unit?
  }

  public int getTemperature() {
    return root.getChild("temperature").getInt("value"); //unit?
  }

  public int getTemperatureMin() {
    return root.getChild("temperature").getInt("min"); //unit?
  }

  public int getTemperatureMax() {
    return root.getChild("temperature").getInt("max"); //unit?
  }

  public String getWeatherCondition() {
    return root.getChild("weather").getString("value");
  }

  /*
  public int getWeatherConditionCode() {
    return channel.getChild("item").getChild("yweather:condition").getInt("code");
  }

  public String getWeekday() {
    return channel.getChild("item").getChild(15).getString("day");
  }
  */

  /*
   * Tomorrow
   */
   /*
  public int getTemperatureLowTomorrow() {
    return channel.getChild("item").getChild(17).getInt("low");
  }

  public int getTemperatureHighTomorrow() {
    return channel.getChild("item").getChild(17).getInt("high");
  }


  public String getWeatherConditionTomorrow() {
    return channel.getChild("item").getChild(17).getString("text");
  }

  public int getWeatherConditionCodeTomorrow(){
    return channel.getChild("item").getChild(17).getInt("code");
  }


  public String getWeekdayTomorrow() {
    return channel.getChild("item").getChild(17).getString("day");
  }
  */
  /*
   * Day After Tomorrow
   *//*
  public int getTemperatureLowDayAfterTomorrow() {
    return channel.getChild("item").getChild(19).getInt("low");
  }

  public int getTemperatureHighDayAfterTomorrow() {
    return channel.getChild("item").getChild(19).getInt("high");
  }


  public String getWeatherConditionDayAfterTomorrow() {
    return channel.getChild("item").getChild(19).getString("text");
  }

  public int getWeatherConditionCodeDayAfterTomorrow(){
    return channel.getChild("item").getChild(19).getInt("code");
  }


  public String getWeekdayDayAfterTomorrow() {
    return channel.getChild("item").getChild(19).getString("day");
  }
*/
}

// Example object for later


class ObjFlash{

  float xinit, yinit, increment;
  float phase = 0;
  float phase_eased, invph;
  float rnd = 100;
  PVector a = new PVector();
  PVector b = new PVector();
  PVector c = new PVector();
  PVector d = new PVector();
  PVector target_a = new PVector(lerp(width*0.05f, width*0.4f, random(1)),lerp(height*0.3f, height*0.7f, random(1)));
  PVector target_b = new PVector(lerp(width*0.6f, width*0.95f, random(1)),lerp(height*0.3f, height*0.7f, random(1)));

  ObjFlash (float xd, float yd, float dr) {
    xinit = xd;
    yinit = yd;
    increment = 1/dr;
  }

  public void update() {

    if (phase < 1) {

      phase_eased = Ease.cubicBoth(Ease.cubicOut(Ease.quinticOut(phase)));
      invph = 1 - phase_eased;

      a.set(lerp(0, target_a.x , phase_eased) + random(-rnd,rnd)*invph, lerp(0, target_a.y , phase_eased) + random(-rnd,rnd)*invph);
      b.set(lerp(width, target_b.x , phase_eased) + random(-rnd,rnd)*invph, lerp(0, target_b.y , phase_eased) + random(-rnd,rnd)*invph);
      c.set(lerp(width, target_b.x , phase_eased) + random(-rnd,rnd)*invph, lerp(height, target_b.y , phase_eased) + random(-rnd,rnd)*invph);
      d.set(lerp(0, target_a.x , phase_eased) + random(-rnd,rnd)*invph, lerp(height, target_a.y , phase_eased) + random(-rnd,rnd)*invph);

      phase += increment;

    }

    else {
      phase = 0;
      target_a.set(lerp(width*0.05f, width*0.4f, random(1)),lerp(height*0.3f, height*0.7f, random(1)));
      target_b.set(lerp(width*0.6f, width*0.95f, random(1)),lerp(height*0.3f, height*0.7f, random(1)));

      // When flash is over, set a new program 
      program_number = 1;
      // & reset counter
      counter = 0;
    }

  }

  public void display() {

    if (phase < 1) {

      // Drawing the shape
      noStroke();
      fill(255);

      beginShape();
      vertex(a.x, a.y);
      vertex(b.x, b.y);
      vertex(c.x, c.y);
      vertex(d.x, d.y);
      endShape(CLOSE);
    }
  }
}
/* Simple one-purpose SVG path & polygon parser  */

public PVector[][][] svgParse(String xml_init) {
  XML xml;
  xml = loadXML(xml_init);

  // Initiate exportable pvector array
  PVector[][][] result = new PVector[2][50][50];

  // Go through all paths
  XML[] paths = xml.getChildren("g/path");

  for (int i = 0; i < paths.length; ++i) {
    String path = paths[i].getString("d");
    String[] points = split(path, ' ');

    // find coordinates for each path
    for (int k = 0; k < points.length; ++k) {

      String point = points[k];
      point = point.replace("M", "");
      point = point.replace("L", "");

      String[] coords = split(point, ',');
      float xCoord = Float.parseFloat(coords[0]);
      float yCoord = Float.parseFloat(coords[1]);

      PVector converted = new PVector(xCoord, yCoord);

      result[0][i][k] = converted;
    }
  }

  // Go through all polys
  XML[] polys = xml.getChildren("g/polygon");

  for (int i = 0; i < polys.length; ++i) {
    String poly = polys[i].getString("points");
    String[] points = split(poly, ' ');

    int dividercounter = 0;

    for (int k = 0; k < points.length; k += 2) {

      float xCoord = Float.parseFloat(points[k]);
      float yCoord = Float.parseFloat(points[k+1]);

      PVector converted = new PVector(xCoord, yCoord);

      result[1][i][dividercounter] = converted;

      dividercounter += 1;
    }
  }

  // Return the whole 3-dimensional array
  return result;

}


/* Function that draws the svg paths */

public void svgDraw(String xml_init) {

  noFill();
  stroke(255);

  // draw path

  // go through paths
  for (int i = 0; i < 50; ++i) {
    // go through points
    if (svgParse(xml_test)[0][i][0] != null) {

      line(
      svgParse(xml_test)[0][i][0].x,
      svgParse(xml_test)[0][i][0].y,
      svgParse(xml_test)[0][i][1].x,
      svgParse(xml_test)[0][i][1].y
      );
    }
  }

  // draw poly

  beginShape();
  // go through polys
  for (int i = 0; i < 50; ++i) {
    // go through points
    for (int k = 0; k < 50; ++k) {
      if (svgParse(xml_test)[1][i][k] != null) {
        vertex(svgParse(xml_test)[1][i][k].x , svgParse(xml_test)[1][i][k].y);
      }
    }
  }
  endShape(CLOSE);


}






















  public void settings() {  size(640, 480, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "smart_crt_tv" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
