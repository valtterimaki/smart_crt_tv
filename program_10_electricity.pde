
/*
Adafruit IO chart fetcher
By Fossa
 */

class ElectricityUse {

  private JSONObject elect_json;
  ////private XML harmonie;
  ////private XML hirlam;
  private boolean reachable;
  private final static String URL_ADAFRUIT_IO = "https://io.adafruit.com/api/v2/fossadouglasi/feeds/elect/data/chart?hours=2&x-aio-key=aio_qDsY88YdeTWpzb4u4JnqPMMyhV5x";
  ////private final static String URL_HIRLAM = "http://opendata.fmi.fi/wfs?service=WFS&version=2.0.0&request=getFeature&storedquery_id=fmi::forecast::hirlam::surface::point::simple&place=turku&";
  private final static int TIMEOUT = 5000;
  ArrayList<Float> data_values = new ArrayList<Float>();
  ArrayList<String> data_times = new ArrayList<String>();
  ////ArrayList<String> data_precipitation = new ArrayList<String>();
  public float anim_phase;
  int last_update = 99;

  public ElectricityUse() {
    update();
    ////println("Last update electricity chart " + lastUpdate());
    anim_phase = 0;
  }

  /* General methods*/

  public boolean checkConnection() {
    try {
      HttpURLConnection connection = (HttpURLConnection) new URL(URL_ADAFRUIT_IO).openConnection();
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
        elect_json = loadJSONObject(URL_ADAFRUIT_IO); // REPLACE WITH URL
        ////harmonie = loadXML(URL_HARMONIE);
        ////hirlam = loadXML(URL_HIRLAM);
        last_update = hour();
      } else {

        /********* TODO!! FIX THIS TO ALSO FMI **********/

        elect_json = loadJSONObject("placeholder_adafruit_io.json"); // FIX THIS to do something useful
        ////harmonie = loadXML("placeholder_forecast_fmi.xml");
        ////hirlam = loadXML("placeholder_forecast_fmi.xml");
        println("Electricity chart - No connection");
      }

      // parse the valus into the arrays for graphs
      parseData();
    }
  }

  /********* TODO!! MAKE THIS PUBLIC AND GENERIC if even needed **********/
  /*
  public String lastUpdate(){
    Date date = new Date();
    return date.toString();
  }
  */


  /* Get forecast data */

  void parseData() {

    // get only the data array from the json
    JSONArray elect_data = elect_json.getJSONArray("data");
    ArrayList<String> times_temp = new ArrayList<String>();
    ArrayList<Float> values_temp = new ArrayList<Float>();


    // Go through the data array
    for (int i = 0; i < elect_data.size(); ++i) {

      // pick the data array contents in order
      JSONArray unit = elect_data.getJSONArray(i);
      // get time
      String time = unit.getString(0);
      // get data
      float value = unit.getFloat(1);

      times_temp.add(time);
      values_temp.add(value);

    }

    data_times = times_temp;
    data_values = values_temp;

    // debug
    //println(times_temp);
    //println(values_temp);

  }


  /* Draw electricity use graph */

  public void drawElect() {

    float margin_left = os_left + 48;
    float margin_right = os_right + 40;
    float margin_top = os_top + 24;
    float margin_bottom = os_bottom + 40;
    float horiz_density = ((width - margin_right - margin_left) / data_values.size());
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
    }


    // draw time scale

    for (int i = 0; i < data_values.size() ; ++i) {
      if (i % 2 == 0) {
        textAlign(CENTER);
        noFill();
        stroke(255, 90);
        line(margin_left + horiz_density * i, margin_top, margin_left + horiz_density * i, height - margin_bottom);
        noStroke();
        fill(255);
        text(
          data_times.get(i).charAt(11) + "" + data_times.get(i).charAt(12),
          margin_left + horiz_density * i,
          height - margin_bottom + scale_size + 8
        );
      }
    }

    for (int i = 0; i < data_values.size() ; ++i) {
      if ((data_times.get(i).charAt(11) + "" + data_times.get(i).charAt(12)).equals("00")) {
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

    for (int i = 0; i < data_values.size() - 1; ++i) {
      if (i +1  > Ease.quinticBoth(anim_phase) * (data_values.size())) {
        break;
      }
      if (data_values.get(i) >= 0) {
        stroke(
          map(data_values.get(i), 0, 10, 0, 255),
          constrain(map(data_values.get(i), 0, 40, 255, 80), 80, 255),
          constrain(map(data_values.get(i), 0, 10, 255, 80), 80, 255)
          );
      } else {
        stroke(
          0,
          constrain(map(data_values.get(i), -30, 0, 0, 255),80, 255),
          255
          );
      }
      line(
        (horiz_density * i + margin_left),
        zeroline - data_values.get(i) * multiplier,
        (horiz_density * (i+1) + margin_left),
        zeroline - data_values.get(i+1) * multiplier
        );
    }

    if (hour() < 12) {
      peaks_to = 16;
    }
    int highest_index = getHighestOrLowestFloat(data_values, "highest", 2, peaks_to);
    int lowest_index = getHighestOrLowestFloat(data_values, "lowest", 2, peaks_to);


    textAlign(CENTER);
    textFont(aspace_light);
    textSize(main_values_size);

    textShaded(
      int(data_values.get(highest_index)) + "°C",
      (horiz_density * highest_index + margin_left),
      zeroline - data_values.get(highest_index) * multiplier - 16 - ((2 - Ease.quinticOut(anim_phase)*2) * 6),
      255, 0, 2
      );
    textShaded(
      int(data_values.get(lowest_index)) + "°C",
      (horiz_density * lowest_index + margin_left),
      zeroline - data_values.get(lowest_index) * multiplier + main_values_size + 8 + ((2 - Ease.quinticOut(anim_phase)*2) * 6),
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
