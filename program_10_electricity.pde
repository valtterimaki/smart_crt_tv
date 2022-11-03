
/*
Adafruit IO chart fetcher
By Fossa
 */

class ElectricityUse {

  private JSONObject elect_json;
  private boolean reachable;
  private final static int TIMEOUT = 5000;
  ArrayList<Float> data_values = new ArrayList<Float>();
  ArrayList<String> data_times = new ArrayList<String>();
  float usage_sum = 0;
  int data_range = 1200;
  public float anim_phase;
  int last_update = 99;

  public ElectricityUse() {
    update();
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
        elect_json = loadJSONObject(URL_ADAFRUIT_IO);
        last_update = hour();
      } else {

        /********* TODO!! FIX THIS TO ALSO FMI **********/

        elect_json = loadJSONObject("placeholder_adafruit_io.json"); // FIX THIS to do something useful
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


  /* Parse data */

  void parseData() {

    // get only the data array from the json
    JSONArray elect_data = elect_json.getJSONArray("data");
    ArrayList<String> times_temp = new ArrayList<String>();
    ArrayList<Float> values_temp = new ArrayList<Float>();


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

    data_times = times_temp;
    data_values = values_temp;

    // debug
    //println(elect_data.size());
    //println(elect_data);
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
      line(margin_left, (vert_density * i) + margin_top, width - margin_right, (vert_density * i) + margin_top);

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

      if ((data_times.get(i).charAt(14) + "" + data_times.get(i).charAt(15)).equals("30")) {
        noFill();
        stroke(255, 90);
        line(margin_left + horiz_density * i, margin_top, margin_left + horiz_density * i, margin_top + graph_height);
      }

      if ((data_times.get(i).charAt(14) + "" + data_times.get(i).charAt(15)).equals("00")) {
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

    textAlign(LEFT);
    textFont(mplus_regular);
    textSize(28);
    textShaded(usage_now + " Wh / min", margin_left + 16, height - margin_bottom - 84, 255, 0, 1);
    textFont(bungee_regular);
    textSize(19);
    textShaded(nf(usage_now * 0.0002885 * 1.24, 0, 5) + " eur / min", margin_left + 16, height - margin_bottom - 64, 255, 0, 1);
    textShaded(nf(usage_now * 0.0002885 * 60 * 1.24, 0, 2) + " eur / h", margin_left + 16, height - margin_bottom - 48, 255, 0, 1);
    textShaded(nf(usage_now * 0.0002885 * 60 * 24 * 1.24, 0, 2) + " eur / day", margin_left + 16, height - margin_bottom - 32, 255, 0, 1);
    textShaded(round(usage_now * 0.0002885 * 60 * 24 * 30 * 1.24) + " eur / month", margin_left + 16, height - margin_bottom - 16, 255, 0, 1);


  }
}
