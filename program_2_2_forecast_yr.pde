
/*
YR.no weather xml fetcher
By Fossa
 */

class ForecastYr {

  private XML forecast;
  private volatile boolean is_fetching = false;
  private volatile boolean reachable = false;
  private final static String URL = "https://api.met.no/weatherapi/locationforecast/2.0/classic?lat=60.478506&lon=22.270944";
  public ArrayList<XML> data_conditions = new ArrayList<XML>();
  public float anim_phase;
  int last_update = 99;

  public ForecastYr() {
    fetch(); // synchronous on setup – that's fine
    println("Forecast YR - initial fetch done: " + lastUpdate());
    anim_phase = 0;
  }

  public String lastUpdate() {
    Date date = new Date();
    return date.toString();
  }

  // ── Called on a background thread via threadForecastYrFetch() ──────────────
  void fetch() {
    try {
      XML loaded = parseXML(fetchStringFromURL(URL));
      if (loaded != null) {
        forecast = loaded;
        reachable = true;
      } else {
        throw new Exception("null response");
      }
    } catch (Exception e) {
      reachable = false;
      forecast = loadXML("placeholder_forecast_yr.xml");
      println("Forecast YR - fetch failed: " + e.getMessage());
    }

    ArrayList<XML> new_conditions = getForecast("conditions");
    data_conditions = new_conditions;

    last_update = hour();
    is_fetching = false;
  }

  // ── Triggers a background refresh; skips if already in-flight or still fresh
  public void update() {
    if (last_update != hour() && !is_fetching) {
      is_fetching = true;
      thread("threadForecastYrFetch");
    }
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
