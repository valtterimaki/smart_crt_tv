
/*
YR.no weather xml fetcher
By Fossa
 */

class ForecastYr {

  private XML forecast;
  private boolean reachable;
  private final static String URL = "https://api.met.no/weatherapi/locationforecast/2.0/classic?lat=60.478506&lon=22.270944";
  private final static int TIMEOUT = 5000;
  public ArrayList<XML> data_conditions = new ArrayList<XML>();
  //ArrayList<XML> data_details = new ArrayList<XML>();
  public float anim_phase;
  int last_update = 99;

  public ForecastYr() {
    update();
    println("Forecast last update YR: " + lastUpdate());
    anim_phase = 0;
  }

  /* General methods*/

  public boolean checkConnection() {
    try {
      HttpsURLConnection connection = (HttpsURLConnection) new URL(URL).openConnection();
      connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9.2.2) Gecko/20100316 Firefox/3.6.2");
      connection.setConnectTimeout(TIMEOUT);
      connection.setReadTimeout(TIMEOUT);
      int responseCode = connection.getResponseCode();
      println("yr no response " + responseCode);
      return (200 <= responseCode && responseCode <= 399);
    } catch (IOException exception) {
      return false;
    }
  }

  public void update() {
    if (last_update != hour()) {

      reachable = checkConnection();

      if (reachable) {
        forecast = loadXML(URL);
        last_update = hour();
      } else {
        forecast = loadXML("placeholder_forecast_yr.xml");
        println("Forecast YR - No connection");
      }
      data_conditions = getForecast("conditions");
      //data_details = getForecast("details");
    }
  }

  public String lastUpdate(){
    Date date = new Date();
    return date.toString();
  }


  /* Get forecast data */

  ArrayList getForecast(String type) {

    XML[] forecast_data = forecast.getChild("product").getChildren("time");

    ArrayList<XML> result = new ArrayList<XML>();
    XML value;

    // Go through all elements
    for (int i = 0; i < forecast_data.length; ++i) {
      if (type.equals("conditions") && forecast_data[i].getChild("location").getChild("symbol") != null) {
        value = forecast_data[i];
        result.add(value);
      }
    }
    return result;
  }

  int findIssMatch() {
    String result = "no result";
    int number = 0;
    for (int i = 0; i < data_conditions.size(); ++i) {
      LocalDateTime compare_start = LocalDateTime.parse(data_conditions.get(i).getString("from").substring(0,16));
      LocalDateTime compare_end = LocalDateTime.parse(data_conditions.get(i).getString("to").substring(0,16));
      //debug
      //println(compare_start + " " + compare_end + " " + iss.next_sighting);
      if (( compare_start.compareTo(iss.next_sighting) < 0 && compare_end.compareTo(iss.next_sighting) > 0 ) || compare_start.compareTo(iss.next_sighting) == 0) {
        result = data_conditions.get(i).getChild("location").getChild("symbol").getString("code");
        number = int(data_conditions.get(i).getChild("location").getChild("symbol").getString("number"));
        break;
      }
    }
    iss.condition = result;
    return number;
  }

}
