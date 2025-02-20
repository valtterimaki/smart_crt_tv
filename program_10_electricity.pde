
/*
Adafruit IO chart fetcher
By Fossa
 */

class ElectricityUse {

  private JSONObject elect_json;
  private JSONObject elect_json_sum;
  private boolean reachable;
  private final static int TIMEOUT = 5000;
  ArrayList<Float> data_values = new ArrayList<Float>();
  ArrayList<String> data_times = new ArrayList<String>();
  float usage_sum;
  int usage_sum_len;
  public float anim_phase;
  int last_update = 99;
  boolean error = false;
  float price_kwh = 0.0000853 + 0.0000191 + 0.00002253; // € per watt hour, sähkö + siirto + sähkövero 
  float price_mon = 13.56; // € per month

  public ElectricityUse() {
    update();
    anim_phase = 0;
  }

  /* General methods*/

  public boolean checkConnection() {
    try {
      HttpURLConnection connection = (HttpURLConnection) new URL("https://io.adafruit.com/").openConnection();
      connection.setConnectTimeout(TIMEOUT);
      connection.setReadTimeout(TIMEOUT);
      int responseCode = connection.getResponseCode();
      println("adafruit io response " + responseCode);
      return (200 <= responseCode && responseCode <= 399);
    } catch (IOException exception) {
      return false;
    }
  }

  public void update() {

    error = false;

    println("updating electicity use stats");

    reachable = checkConnection();

    if (reachable) {
      delay(500);
      try {
        elect_json = loadJSONObject(URL_ADAFRUIT_IO_4H);
        elect_json_sum = loadJSONObject(URL_ADAFRUIT_IO_24H);
      } catch (Exception e) {
        error = true;
        elect_json = loadJSONObject("placeholder_adafruit_io.json");
        elect_json_sum = loadJSONObject("placeholder_adafruit_io.json");
      }
      last_update = hour();
    } else {
      error = true;
      elect_json = loadJSONObject("placeholder_adafruit_io.json");
      elect_json_sum = loadJSONObject("placeholder_adafruit_io.json");
      println("Electricity chart - No connection");
    }

    // if for some reason we cannot get the data
    if (error == false) {
      if (elect_json.getJSONArray("data") == null) {
        error = true;
        elect_json = loadJSONObject("placeholder_adafruit_io.json"); // FIX THIS to do something useful
        elect_json_sum = loadJSONObject("placeholder_adafruit_io.json");
        println("Electricity chart - Data was not gotten for some reason");
      }
    }

    // parse the valus into the arrays for graphs
    parseData();

  }

  /********* TODO!! MAKE THIS PUBLIC AND GENERIC if even needed **********/
  /*
  public String lastUpdate(){
    Date date = new Date();
    return date.toString();
  }
  */


  /* Parse data */

  void parseData() {

    // get only the data array from the json
    JSONArray elect_data = elect_json.getJSONArray("data");
    JSONArray elect_data_sum = elect_json_sum.getJSONArray("data");
    ArrayList<String> times_temp = new ArrayList<String>();
    ArrayList<Float> values_temp = new ArrayList<Float>();

    usage_sum = 0;
    usage_sum_len = elect_data_sum.size();

    // Go through the data array, only count data range
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

    for (int i = 0; i < elect_data_sum.size(); ++i) {

      // pick the data array contents in order
      JSONArray unit_sum = elect_data_sum.getJSONArray(i);
      // get data
      float value_sum = unit_sum.getFloat(1);

      usage_sum += value_sum;

    }

    data_times = times_temp;
    data_values = values_temp;

    // debug
    println("usage 24h total " + usage_sum);
    //println(elect_data.size());
    //println(elect_data);
    //println(elect_data_sum);
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
    float graph_height = (height - margin_top - margin_bottom ) * 0.6;
    float value_scale = 200;
    float multiplier = graph_height / value_scale;
    float vert_density = graph_height / 10 ;
    int main_values_size = 32;
    int scale_size = 15;
    int gap = 10;
    int dash_gap = 9;
    float usage_now = data_values.get(data_values.size() - 1);


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


    // draw electricity usage value scale

    for (int i = 0; i <= 10; ++i) {
      noFill();
      stroke(255, 90);
      line(margin_left, ceil((vert_density * i) + margin_top)+0.5, width - margin_right, ceil((vert_density * i) + margin_top)+0.5);

      noStroke();
      fill(255);
      textAlign(RIGHT);
      text(
        int(value_scale - (i * (value_scale/10))),
        margin_left - 8,
        (vert_density * i) + margin_top + 5
        );
    }


    // draw time scale
    textAlign(CENTER);
    noFill();
    stroke(255);
    line(width - margin_right, margin_top, width - margin_right, margin_top + graph_height);

    for (int i = 0; i < data_values.size() - 1 ; ++i) {

      if ((data_times.get(i).charAt(14) + "" + data_times.get(i).charAt(15)).equals("30") && error == false) {
        noFill();
        stroke(255, 90);
        line(margin_left + horiz_density * i, margin_top, margin_left + horiz_density * i, margin_top + graph_height);
      }

      if ((data_times.get(i).charAt(14) + "" + data_times.get(i).charAt(15)).equals("00") && error == false) {
        noFill();
        stroke(255, 90);
        line(margin_left + horiz_density * i, margin_top, margin_left + horiz_density * i, margin_top + graph_height);
        noStroke();
        fill(255);
        String scale_hour = data_times.get(i).charAt(11) + "" + data_times.get(i).charAt(12);
        text(
          ((int(scale_hour) + 2) % 24) + ":00",
          margin_left + horiz_density * i,
          margin_top + graph_height + scale_size + 8
        );
      }
    }

    // Draw the electricity use graph

    noFill();
    stroke(255);
    strokeWeight(3);
    strokeCap(ROUND);
    textAlign(LEFT);

    if (error == false) {
      for (int i = 0; i < data_values.size() - 1; ++i) {
        if (i +1  > Ease.quinticBoth(anim_phase) * (data_values.size())) {
          break;
        }
        stroke(
          map(data_values.get(i), 0, 50, 0, 255),
          constrain(map(data_values.get(i), 0, 200, 255, 80), 80, 255),
          constrain(map(data_values.get(i), 0, 50, 255, 80), 80, 255)
          );
        line(
          (horiz_density * i + margin_left),
          margin_top + graph_height - data_values.get(i) * multiplier,
          (horiz_density * (i+1) + margin_left),
          margin_top + graph_height - data_values.get(i+1) * multiplier
          );
      }

      textFont(lastwaerk_regular);
      textSize(56);
      textShaded(usage_now + "", margin_left + 16, height - margin_bottom - 120, 255, 0, 1);
      float usage_textwidth = textWidth(usage_now + "");
      textFont(robotomono_light);
      textSize(22);
      textShaded(" Wh / min", margin_left + 16 + usage_textwidth, height - margin_bottom - 120, 255, 0, 1);

      textFont(robotomono_light);
      textSize(22);
      textShaded(nf(usage_now * price_kwh, 0, 5) + " € / min", margin_left + 16, height - margin_bottom - 86, 255, 0, 1);
      textShaded(nf(usage_now * price_kwh * 60 + (price_mon / 30 / 24), 0, 2) + " € / h", margin_left + 16, height - margin_bottom - 64, 255, 0, 1);
      textShaded(nf(usage_now * price_kwh * 60 * 24 + (price_mon / 30), 0, 2) + " € / päivä", margin_left + 16, height - margin_bottom - 42, 255, 0, 1);

      textShaded("Avg. " + round(usage_sum / usage_sum_len) + " Wh / min", margin_left + 300, height - margin_bottom - 64, 255, 0, 1); // 60 is the resolution of the feed
      textShaded(nf(usage_sum * price_kwh * 60 + (price_mon / 30), 0, 2) + " € / viime 24h", margin_left + 300, height - margin_bottom - 42, 255, 0, 1);
      textShaded(nf(usage_sum * price_kwh * 60 * 24 + price_mon, 0, 2) + " € / kk proj.", margin_left + 300, height - margin_bottom - 20, 255, 0, 1);

      textFont(robotomono_semibold);
      textSize(22);
      textShaded(round(usage_now * price_kwh * 60 * 24 * 30 + price_mon) + " € / kk", margin_left + 16, height - margin_bottom - 20, 255, 0, 1);

    } else {
      textFont(lastwaerk_regular);
      textSize(56);
      textShaded("ERROR NO DATA ! ", margin_left + 16, height - margin_bottom - 60, 255, 0, 1);
    }

    textFont(rajdhani_light);
    textSize(32);
    textShaded("DENKIMATIC", margin_left + 300, height - margin_bottom - 120, 255, 0, 1);
    textShaded("DENKIMATIC", margin_left + 302, height - margin_bottom - 120, 255, 0, 1);
  
  }
}
