
/*
FMI weather xml fetcher
By Fossa
 */

class ForecastFmi {

  private XML harmonie;
  private boolean reachable;
  private final static String URL_HARMONIE = "http://opendata.fmi.fi/wfs?service=WFS&version=2.0.0&request=getFeature&storedquery_id=fmi::forecast::harmonie::surface::point::simple&place=turku&";
  private final static int TIMEOUT = 5000;
  ArrayList<String> data_temperatures = new ArrayList<String>();
  ArrayList<String> data_times = new ArrayList<String>();
  ArrayList<String> data_precipitation = new ArrayList<String>();
  public float anim_phase;
  int last_update = 99;

  public ForecastFmi() {
    update();
    println("Forecast last update FMI: " + lastUpdate());
    anim_phase = 0;
  }

  /* General methods*/

  public boolean checkConnection() {
    try {
      HttpURLConnection connection = (HttpURLConnection) new URL("http://opendata.fmi.fi/").openConnection();
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

      reachable = checkConnection();

      if (reachable) {
        harmonie = loadXML(URL_HARMONIE);
        last_update = hour();
      } else {
        harmonie = loadXML("placeholder_forecast_fmi.xml");
        println("Forecast FMI - No connection");
      }

      data_times = getForecast("Time");
      data_temperatures = getForecast("Temperature");
      data_precipitation = getForecast("PrecipitationAmount");
    }
  }

  public String lastUpdate(){
    Date date = new Date();
    return date.toString();
  }


  /* Get forecast data */

  ArrayList getForecast(String type) {

    XML[] forecast_data = harmonie.getChildren("wfs:member");

    // get precipitation
    if (type.equals("PrecipitationAmount")) {
      forecast_data = harmonie.getChildren("wfs:member");
    }

    ArrayList<String> result = new ArrayList<String>();
    String type_test, value;
    // Use these to trim the result to certain timeframe
    int start_at = 0;
    int end_at = 32;
    int count = 0;

    // Go through all elements
    for (int i = 0; i < forecast_data.length; ++i) {
      // Check what data is in the element
      type_test = forecast_data[i].getChild("BsWfs:BsWfsElement").getChild("BsWfs:ParameterName").getContent();

      // Get all unique times
      if (type == "Time" && type_test.equals("Temperature")) {
        value = forecast_data[i].getChild("BsWfs:BsWfsElement").getChild("BsWfs:Time").getContent();
        if (count >= start_at && count <= end_at) {
          result.add(value);
        }
        count++;
      }

      // Get all weather data by type
      if (type_test.equals(type)) {
        value = forecast_data[i].getChild("BsWfs:BsWfsElement").getChild("BsWfs:ParameterValue").getContent();
        if (count >= start_at && count <= end_at) {
          result.add(value);
        }
        count++;
      }
    }
    return result;
  }


  /* Draw forecast graph */

  public void drawForecast() {

    float margin_left = os_left + 48;
    float margin_right = os_right + 40;
    float margin_top = os_top + 24;
    float margin_bottom = os_bottom + 40;
    float horiz_density = ((width - margin_right - margin_left) / data_temperatures.size());
    float vert_density = (height - margin_top - margin_bottom) / 7 ;
    float zeroline = vert_density * 4 + margin_top;
    float multiplier = vert_density / 10;
    int main_values_size = 32;
    int scale_size = 15;
    int gap = 10;
    int dash_gap = 9;
    int peaks_to = 24;


    // very simple advance animation phase
    if (anim_phase < 1) {
      anim_phase += 0.01;
    }


    // Draw precipitation amt

    strokeWeight(3);

    for (int i = 0; i < data_precipitation.size() - 1; ++i) {

      // Animate here
      if (i + 1 > Ease.quinticBoth(anim_phase) * data_precipitation.size()) {
        break;
      }

      stroke(
        50,
        map(float(data_precipitation.get(i)), 0, 4, 130, 100),
        map(float(data_precipitation.get(i)), 0, 4, 130, 255)
      );

      int subt_offs;
      if (i > 0) {subt_offs = 1;} else {subt_offs = 0;}
      rectStriped(
        (horiz_density * i + margin_left),
        height - margin_bottom,
        horiz_density -4,
        -map(float(data_precipitation.get(i)) - float(data_precipitation.get(i - subt_offs)), 0, 14, 0, (height - margin_top - margin_bottom)),
        4,
        radians(45)
      );
    }


    // Draw the grid

    noFill();
    strokeWeight(1);
    strokeCap(SQUARE);
    textFont(aspace_regular);
    textSize(scale_size);


    // draw temperature/precipitation scale

    for (int i = 0; i <= 7; ++i) {
      noFill();
      stroke(255, 90);
      line(margin_left, (vert_density * i) + margin_top, width - margin_right, (vert_density * i) + margin_top);
      noStroke();
      fill(255);
      textAlign(RIGHT);
      text(
        40 - (10 * i),
        margin_left - 8,
        (vert_density * i) + margin_top + 5
        );
      textAlign(LEFT);
      text(
        14 - (2 * i),
        width - margin_right + 8,
        (vert_density * i) + margin_top + 5
        );
    }


    // draw time scale

    for (int i = 0; i < data_temperatures.size() ; ++i) {
      if (i % 2 == 0) {
        textAlign(CENTER);
        noFill();
        stroke(255, 90);
        line(margin_left + horiz_density * i, margin_top, margin_left + horiz_density * i, height - margin_bottom);
        noStroke();
        fill(255);
        text(
          nf((int(data_times.get(i).charAt(11) + "" + data_times.get(i).charAt(12)) + 2) % 24, 2, 0),
          margin_left + horiz_density * i,
          height - margin_bottom + scale_size + 8
        );
      }
    }

    for (int i = 0; i < data_temperatures.size() ; ++i) {
      if (((int(data_times.get(i).charAt(11) + "" + data_times.get(i).charAt(12)) + 2) % 24) == 0 ) {
        textAlign(LEFT);
        noFill();
        stroke(255);
        line(margin_left + horiz_density * i, margin_top, margin_left + horiz_density * i, height - margin_bottom);
        textShaded(data_times.get(i).substring(8,10) + "." + data_times.get(i).substring(5,7), margin_left + horiz_density * i + 8, margin_top + 16, 255, 0, 2);
      }
    }


    // draw zeroline

    noStroke();
    fill(255);
    rect(margin_left, zeroline - 1, width - margin_left - margin_right, 1);


    // Draw the temperature graph

    noFill();
    stroke(255);
    strokeWeight(3);
    strokeCap(ROUND);

    for (int i = 0; i < data_temperatures.size() - 1; ++i) {
      if (i +1  > Ease.quinticBoth(anim_phase) * (data_temperatures.size())) {
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
        (horiz_density * i + margin_left),
        zeroline - float(data_temperatures.get(i)) * multiplier,
        (horiz_density * (i+1) + margin_left),
        zeroline - float(data_temperatures.get(i+1)) * multiplier
        );
    }

    if (hour() < 12) {
      peaks_to = 16;
    }
    int highest_index = getHiOrLoIndexString(data_temperatures, "highest", 2, peaks_to);
    int lowest_index = getHiOrLoIndexString(data_temperatures, "lowest", 2, peaks_to);


    textAlign(CENTER);
    textFont(aspace_light);
    textSize(main_values_size);

    textShaded(
      int(data_temperatures.get(highest_index)) + "°C",
      (horiz_density * highest_index + margin_left),
      zeroline - float(data_temperatures.get(highest_index)) * multiplier - 16 - ((2 - Ease.quinticOut(anim_phase)*2) * 6),
      255, 0, 2
      );
    textShaded(
      int(data_temperatures.get(lowest_index)) + "°C",
      (horiz_density * lowest_index + margin_left),
      zeroline - float(data_temperatures.get(lowest_index)) * multiplier + main_values_size + 8 + ((2 - Ease.quinticOut(anim_phase)*2) * 6),
      255, 0, 2
      );

    textAlign(LEFT);
    textFont(mplus_regular);
    textSize(28);
    textShaded("天気予報", margin_left + 16, height - margin_bottom - 52, 255, 0, 1);
    textFont(bungee_regular);
    textSize(19);
    textShaded("ENNUSTE, HARMONIE", margin_left + 16, height - margin_bottom - 32, 255, 0, 1);
    textShaded(data_times.get(2).substring(0,10), margin_left + 16, height - margin_bottom - 16, 255, 0, 1);


    // TEST TEST TEST
    //stroke(255, 0, 0);
    //rectStriped(0, height, 20, -200, 4, radians(millis()/50));


  }
}
