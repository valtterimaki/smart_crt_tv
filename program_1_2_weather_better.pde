
/*
FMI weather xml fetcher
By Fossa
 */

class WeatherNew {

  private XML forecast;
  private boolean reachable;
  private final static String  URL = "http://opendata.fmi.fi/wfs?service=WFS&version=2.0.0&request=getFeature&storedquery_id=fmi::forecast::hirlam::surface::point::simple&place=turku&";
  private final static int TIMEOUT = 5000;
  public float anim_phase;
  int last_update;

  public WeatherNew() {
    //last_update = hour();
    update();
    println("Last update: " + lastUpdate());
    anim_phase = 0;
  }

  /* General methods*/

  public boolean checkConnection() {
    try {
      HttpURLConnection connection = (HttpURLConnection) new URL(URL).openConnection();
      connection.setConnectTimeout(TIMEOUT);
      connection.setReadTimeout(TIMEOUT);
      int responseCode = connection.getResponseCode();
      println(responseCode);
      return (200 <= responseCode && responseCode <= 399);
    } catch (IOException exception) {
      return false;
    }
  }

  public void update() {
    if (last_update != hour()) {
      println("CHECK");

      reachable = checkConnection();

      if (reachable) {
        forecast = loadXML(URL);
        last_update = hour();
      } else {
        forecast = loadXML("weather_data_placeholder.xml");
        println("No connection");
      }
    }
  }

  public String lastUpdate(){
    Date date = new Date();
    return date.toString();
  }


  /* Get forecast data */

  public ArrayList getForecast(String type) {

    XML[] forecast_data = forecast.getChildren("wfs:member");
    ArrayList<String> result = new ArrayList<String>();
    String type_test, value;

    // Go through all elements
    for (int i = 0; i < forecast_data.length; ++i) {
      // Check what data is in the element
      type_test = forecast_data[i].getChild("BsWfs:BsWfsElement").getChild("BsWfs:ParameterName").getContent();

      // Get all unique times
      if (type == "Time" && type_test.equals("Temperature")) {
        value = forecast_data[i].getChild("BsWfs:BsWfsElement").getChild("BsWfs:Time").getContent();
        result.add(value);
      }

      // Get all temperatures
      if (type_test.equals(type)) {
        value = forecast_data[i].getChild("BsWfs:BsWfsElement").getChild("BsWfs:ParameterValue").getContent();
        //TEST //value = str(-30 + i/10 );
        result.add(value);
      }
    }
    return result;
  }


  /* Draw forecast graph */

  public void drawForecast() {

    ArrayList<String> data_temperatures = getForecast("Temperature");
    ArrayList<String> data_times = getForecast("Time");


    float margin = 64;
    float horiz_density = ((width - margin * 2) / data_temperatures.size());
    float vert_density = (height - (margin * 2)) / 7 ;
    float zeroline = vert_density * 4 + margin;
    float multiplier = vert_density / 10;
    int main_values_size = 32;
    int scale_size = 15;
    int gap = 10;
    int dash_gap = 9;


    // very simple advance animation phase
    if (anim_phase < 1) {
      anim_phase += 0.01;
    }


    // Draw the grid

    noFill();
    strokeWeight(1);
    strokeCap(SQUARE);
    textFont(aspace_regular);
    textSize(scale_size);

    // draw temperature scale
    textAlign(RIGHT);
    stroke(255, 100);
    for (int i = 0; i <= 7; ++i) {
      line(margin, (vert_density * i) + margin, width - margin, (vert_density * i) + margin);
      text(
        40 - (10 * i),
        margin - 8,
        (vert_density * i) + margin + 5
        );
    }

    // draw time scale
    // NOTE: 2 first ones are omitted as they are from past

    for (int i = 2; i < data_temperatures.size() ; ++i) {
      if (i % 2 == 0) {
        textAlign(CENTER);
        stroke(255, 100);
        line(margin + horiz_density * i, margin, margin + horiz_density * i, height - margin);
        text(
          data_times.get(i).charAt(11) + "" + data_times.get(i).charAt(12),
          margin + horiz_density * i,
          height - margin + scale_size + 8
        );
      }
      if ((data_times.get(i).charAt(11) + "" + data_times.get(i).charAt(12)).equals("00")) {
        textAlign(LEFT);
        stroke(255);
        line(margin + horiz_density * i, margin, margin + horiz_density * i, height - margin);
        text(data_times.get(i).substring(8,10) + "." + data_times.get(i).substring(5,7), margin + horiz_density * i + 8, margin + 16);
      }
    }


    // draw zeroline
    noStroke();
    fill(255);
    rect(margin, zeroline - 1, width - margin*2, 1);


    // Draw the graph

    noFill();
    stroke(255);
    strokeWeight(3);
    strokeCap(ROUND);

    // NOTE: 2 first ones are omitted as they are from past
    for (int i = 2; i < data_temperatures.size() - 1; ++i) {
      if (i - 1 > Ease.quinticBoth(anim_phase) * (data_temperatures.size() - 1)) {
        break;
      }
      if (float(data_temperatures.get(i)) >= 0) {
        stroke(
          map(float(data_temperatures.get(i)), 0, 10, 0, 255),
          constrain(map(float(data_temperatures.get(i)), 0, 40, 255, 80), 80, 255),
          constrain(map(float(data_temperatures.get(i)), 0, 10, 255, 80), 80, 255)
          );
      } else {
        stroke(
          0,
          constrain(map(float(data_temperatures.get(i)), -30, 0, 0, 255),80, 255),
          255
          );
      }
      line(
        (horiz_density * i + margin),
        zeroline - float(data_temperatures.get(i)) * multiplier,
        (horiz_density * (i+1) + margin),
        zeroline - float(data_temperatures.get(i+1)) * multiplier
        );
    }

    int highest_index = getHighestOrLowest(data_temperatures, "highest", 2);
    int lowest_index = getHighestOrLowest(data_temperatures, "lowest", 2);


    textAlign(CENTER);
    textFont(aspace_light);
    textSize(main_values_size);

    noStroke();
    fill(0);
    rect(
      ((horiz_density * highest_index + margin) - (textWidth(data_temperatures.get(highest_index) + "°C")) / 3 ),
      zeroline - float(data_temperatures.get(highest_index)) * multiplier - 12,
      textWidth(data_temperatures.get(highest_index) + "°C") /1.5,
      -main_values_size
    );
    rect(
      ((horiz_density * lowest_index + margin) - (textWidth(data_temperatures.get(lowest_index) + "°C")) / 3 ),
      zeroline - float(data_temperatures.get(lowest_index)) * multiplier + main_values_size + 12,
      textWidth(data_temperatures.get(lowest_index) + "°C") /1.5,
      -main_values_size
    );

    fill(255);

    text(
      int(data_temperatures.get(highest_index)) + "°C",
      (horiz_density * highest_index + margin),
      zeroline - float(data_temperatures.get(highest_index)) * multiplier - 16 - ((2 - Ease.quinticOut(anim_phase)*2) * 6)
      );
    text(
      int(data_temperatures.get(lowest_index)) + "°C",
      (horiz_density * lowest_index + margin),
      zeroline - float(data_temperatures.get(lowest_index)) * multiplier + main_values_size + 8 + ((2 - Ease.quinticOut(anim_phase)*2) * 6)
      );

    textAlign(LEFT);
    textFont(mplus_regular);
    textSize(28);
    text("天気予報", margin + 16, height - margin - 52);
    textFont(bungee_regular);
    textSize(19);
    text("ENNUSTE", margin + 16, height - margin - 32);
    text(data_times.get(2).substring(0,10), margin + 16, height - margin - 16);

  }


}
