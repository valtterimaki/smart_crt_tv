
/*
Open weather map xml fetcher
By Fossa
 */

class Weather {

  // Parsed XML tree from the API response
  private XML root;
  // Flag to prevent overlapping background fetch threads
  private volatile boolean is_fetching = false;
  // True when the last fetch succeeded; false when offline/API error
  private volatile boolean reachable = false;
  // Tracks the hour when data was last successfully fetched (99 = never)
  private int last_update = 99;
  // Loaded from data/owm_api_key.txt (gitignored) – never hardcode the key
  private String api_key = "";
  // OpenWeatherMap API endpoint – Turku, FI, metric units, XML format, Finnish language
  private final static String URL_BASE = "http://api.openweathermap.org/data/2.5/weather?q=Turku,fi&units=metric&mode=xml&lang=fi&appid=";

  // OWM city ID for Turku (used as a reference, not in the URL above)
  int citycode = 633679;

  // Constructor: performs an immediate synchronous fetch on startup so data is
  // available before the first draw() call
  public Weather() {
    String[] keys = loadStrings("owm_api_key.txt");
    if (keys != null && keys.length > 0) api_key = keys[0].trim();
    fetch(); // synchronous on setup – that's fine
    println("Current weather - initial fetch done: " + lastUpdate());
  }

  // ── Called on a background thread via threadWeatherFetch() ─────────────────
  // Downloads and parses the XML feed. On success, updates root and marks the
  // current hour so update() won't re-fetch until the next hour. On failure,
  // falls back to a local placeholder XML file so the UI still has data.
  void fetch() {
    try {
      XML loaded = parseXML(fetchStringFromURL(URL_BASE + api_key));
      if (loaded != null) {
        root = loaded;
        reachable = true;
        last_update = hour();
      }
    } catch (Exception e) {
      reachable = false;
      // Only load the placeholder if we have no data at all yet
      if (root == null) root = loadXML("weather_data_placeholder.xml");
      println("Current weather - fetch failed: " + e.getMessage());
    } finally {
      // Always clear the in-flight flag so future update() calls can proceed
      is_fetching = false;
    }
  }

  // ── Triggers a background refresh; skips if already in-flight or still fresh ──
  // Called each frame from the main draw loop. Spawns a background thread at
  // most once per hour to avoid blocking the UI.
  public void update() {
    if (last_update != hour() && !is_fetching) {
      is_fetching = true;
      thread("threadWeatherFetch");
    }
  }

  // Returns the current wall-clock time as a human-readable string (used for
  // logging the time of the last successful fetch)
  public String lastUpdate() {
    Date date = new Date();
    return date.toString();
  }


  /* ── Current weather data accessors ────────────────────────────────────────
     All methods below navigate the parsed XML tree and return individual
     weather values. They mirror the structure of the OWM XML response. */

  // City name as returned by the API (e.g. "Turku")
  public String getCityName() {
    return root.getChild("city").getString("name");
  }

  // Two-letter country code (e.g. "FI")
  public String getCountryName() {
    return root.getChild("city/country").getContent();
  }

  // Current wind speed in m/s
  public float getWindSpeed() {
    return root.getChild("wind/speed").getFloat("value");
  }

  // Sunrise time in ISO-8601 format (UTC)
  public String getSunrise() {
    return root.getChild("city/sun").getString("rise");
  }

  // Sunset time in ISO-8601 format (UTC)
  public String getSunset() {
    return root.getChild("city/sun").getString("set");
  }

  // UTC offset for the city's timezone in seconds
  public String getTimezone() {
    return root.getChild("city/timezone").getContent();
  }

  // Atmospheric pressure in hPa
  public int getPressure() {
    return root.getChild("pressure").getInt("value");
  }

  // Relative humidity as a percentage (0–100)
  public int getHumidity() {
    return root.getChild("humidity").getInt("value");
  }

  // Current temperature in °C
  public float getTemperature() {
    return root.getChild("temperature").getFloat("value");
  }

  // Today's forecast minimum temperature in °C
  public float getTemperatureMin() {
    return root.getChild("temperature").getFloat("min");
  }

  // Today's forecast maximum temperature in °C
  public float getTemperatureMax() {
    return root.getChild("temperature").getFloat("max");
  }

  // Human-readable weather condition description in the configured language (Finnish)
  public String getWeatherCondition() {
    return root.getChild("weather").getString("value");
  }

  // OWM weather condition ID (e.g. 800 = clear sky); used to select icons/logic
  public int getWeatherConditionID() {
    return root.getChild("weather").getInt("number");
  }

  // OWM icon code (e.g. "01d") that maps to a weather icon image
  public String getWeatherConditionIcon() {
    return root.getChild("weather").getString("icon");
  }

  // ISO-8601 timestamp of when the weather data was last updated on the server
  public String getLastUpdate() {
    return root.getChild("lastupdate").getString("value");
  }

}
