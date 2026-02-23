
/*
Open weather map xml fetcher
By Fossa
 */

class Weather {

  private XML root;
  private volatile boolean is_fetching = false;
  private volatile boolean reachable = false;
  private int last_update = 99;
  private final static String URL = "http://api.openweathermap.org/data/2.5/weather?q=Turku,fi&appid=252d087e98bfe7e2d4bfa4991e0f4671&units=metric&mode=xml&lang=fi";

  int citycode = 633679;

  public Weather() {
    fetch(); // synchronous on setup – that's fine
    println("Current weather - initial fetch done: " + lastUpdate());
  }

  // ── Called on a background thread via threadWeatherFetch() ─────────────────
  void fetch() {
    try {
      XML loaded = parseXML(fetchStringFromURL(URL));
      if (loaded != null) {
        root = loaded;
        reachable = true;
        last_update = hour();
      }
    } catch (Exception e) {
      reachable = false;
      if (root == null) root = loadXML("weather_data_placeholder.xml");
      println("Current weather - fetch failed: " + e.getMessage());
    } finally {
      is_fetching = false;
    }
  }

  // ── Triggers a background refresh; skips if already in-flight or still fresh
  public void update() {
    if (last_update != hour() && !is_fetching) {
      is_fetching = true;
      thread("threadWeatherFetch");
    }
  }

  public String lastUpdate() {
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

  public float getWindSpeed() {
    return root.getChild("wind/speed").getFloat("value");
  }

  public String getSunrise() {
    return root.getChild("city/sun").getString("rise");
  }

  public String getSunset() {
    return root.getChild("city/sun").getString("set");
  }

  public String getTimezone() {
    return root.getChild("city/timezone").getContent();
  }

  public int getPressure() {
    return root.getChild("pressure").getInt("value");
  }

  public int getHumidity() {
    return root.getChild("humidity").getInt("value");
  }

  public float getTemperature() {
    return root.getChild("temperature").getFloat("value");
  }

  public float getTemperatureMin() {
    return root.getChild("temperature").getFloat("min");
  }

  public float getTemperatureMax() {
    return root.getChild("temperature").getFloat("max");
  }

  public String getWeatherCondition() {
    return root.getChild("weather").getString("value");
  }

  public int getWeatherConditionID() {
    return root.getChild("weather").getInt("number");
  }

  public String getWeatherConditionIcon() {
    return root.getChild("weather").getString("icon");
  }

  public String getLastUpdate() {
    return root.getChild("lastupdate").getString("value");
  }

}
