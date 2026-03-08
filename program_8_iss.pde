// ISS tracker

class IssTracker {

  private volatile JSONObject iss_data;
  private volatile JSONArray passes;
  private volatile boolean reachable = false;
  private volatile boolean is_fetching = false;
  private String api_key = "";
  private final static String URL_BASE = "https://api.n2yo.com/rest/v1/satellite/visualpasses/25544/60.4518/22.2486/10/10/15/&apiKey=";
  public float anim_phase;
  int last_update = 99;
  String condition;
  LocalDateTime next_sighting;
  LocalDateTime current_time;
  int current_sighting_no;
  PShape iss_logo;
  Animator anim1 = new Animator();

  public IssTracker() {
    String[] keys = loadStrings("n2yo_api_key.txt");
    if (keys != null && keys.length > 0) api_key = keys[0].trim();
    fetch(); // synchronous on setup – that's fine
    current_time = LocalDateTime.now();
    updateSightingIndex();
    println("ISS - initial fetch done: " + lastUpdate());
    iss_logo = loadShape("img/iss_logo2.svg");
    iss_logo.disableStyle();
  }

  public String lastUpdate() {
    Date date = new Date();
    return date.toString();
  }

  // ── Called on a background thread via threadIssFetch() ─────────────────────
  void fetch() {
    try {
      String response = fetchStringFromURL(URL_BASE + api_key);
      JSONObject json = parseJSONObject(response);
      if (json != null && json.hasKey("passes")) {
        iss_data = json;
        passes = json.getJSONArray("passes");
        reachable = true;
      } else {
        throw new Exception("No passes in response");
      }
    } catch (Exception e) {
      reachable = false;
      iss_data = loadJSONObject("iss_data_placeholder.json");
      passes = iss_data.getJSONArray("passes");
      println("ISS - fetch failed: " + e.getMessage());
    } finally {
      last_update = hour();
      is_fetching = false;
    }
  }

  void updateSightingIndex() {
    current_sighting_no = 0;
    for (int i = 0; i < passes.size(); ++i) {
      if (current_time.compareTo(parseData(i)) < 0) { current_sighting_no = i; break; }
    }
    if (passes.size() > 0) next_sighting = parseData(current_sighting_no);
    else next_sighting = current_time;
  }

  // ── Triggers background fetch if stale; also refreshes the sighting index
  // from whatever data is currently loaded (no network call here).
  public void update() {
    anim1.reset();
    current_time = LocalDateTime.now();

    if (last_update != hour() && !is_fetching) {
      is_fetching = true;
      thread("threadIssFetch");
    }

    // Refresh sighting index from current (possibly stale) data – fast, no I/O
    passes = iss_data.getJSONArray("passes");
    updateSightingIndex();
    // forecast_yr is now updated independently in smart_crt_tv.pde
  }

  String getData(int idx, String field) {
    try {
      JSONObject pass = passes.getJSONObject(idx);
      switch (field) {
        case "Date":      return formatDate(pass.getLong("startUTC"));
        case "Time":      return formatTime(pass.getLong("startUTC"));
        case "Duration":  return formatDuration(pass.getInt("duration"));
        case "Maximum Elevation":
          return "Maximum Elevation: " + nf(pass.getFloat("maxEl"), 0, 1) + "\u00b0";
        case "Approach":
          return "Approach: " + nf(pass.getFloat("startEl"), 0, 1) + "\u00b0 above " + pass.getString("startAzCompass");
        case "Departure":
          return "Departure: " + nf(pass.getFloat("endEl"), 0, 1) + "\u00b0 above " + pass.getString("endAzCompass");
        case "Magnitude":
          return "Magnitude: " + nf(pass.getFloat("mag"), 0, 1);
        default:
          return field + ": N/A";
      }
    } catch (Exception e) {
      println("error in sighting number");
      return field + ": error";
    }
  }

  LocalDateTime parseData(int idx) {
    long utc = passes.getJSONObject(idx).getLong("startUTC");
    return LocalDateTime.ofInstant(
      java.time.Instant.ofEpochSecond(utc),
      java.time.ZoneId.systemDefault()
    );
  }

  String formatDate(long utc) {
    LocalDateTime dt = LocalDateTime.ofInstant(
      java.time.Instant.ofEpochSecond(utc),
      java.time.ZoneId.systemDefault()
    );
    return "Date: " + dt.getMonth().getDisplayName(java.time.format.TextStyle.FULL, java.util.Locale.ENGLISH)
      + " " + dt.getDayOfMonth() + ", " + dt.getYear();
  }

  String formatTime(long utc) {
    LocalDateTime dt = LocalDateTime.ofInstant(
      java.time.Instant.ofEpochSecond(utc),
      java.time.ZoneId.systemDefault()
    );
    return "Time: " + nf(dt.getHour(), 2) + ":" + nf(dt.getMinute(), 2);
  }

  String formatDuration(int seconds) {
    int mins = seconds / 60;
    int secs = seconds % 60;
    if (mins > 0) return "Duration: " + mins + " min " + secs + " sec";
    return "Duration: " + secs + " sec";
  }

  int urgency() {
    int result = 0;
    if (localDateTimeDiff(current_time, next_sighting, "d") != 0) {
      result = 1;
    }
    if (localDateTimeDiff(current_time, next_sighting, "d") == 0 && localDateTimeDiff(current_time, next_sighting, "h") != 0) {
      result = 2;
    }
    if (localDateTimeDiff(current_time, next_sighting, "d") == 0 && localDateTimeDiff(current_time, next_sighting, "h") == 0 && localDateTimeDiff(current_time, next_sighting, "m") < 10) {
      result = 3;
    }
    return result;
  }

  String timeLeft() {
    String result = "";
    if (urgency() == 1) {
      result = "In about " + str(localDateTimeDiff(current_time, next_sighting, "d")) + " days";
    }
    if (urgency() == 2) {
      result = "In " + nf(localDateTimeDiff(current_time, next_sighting, "h")) + " hours and " + nf(localDateTimeDiff(current_time, next_sighting, "m")) + " minutes";
    }
    if (urgency() == 3) {
      result = "In " + nf(localDateTimeDiff(current_time, next_sighting, "m")) + " minutes";
    }
    return result;
  }

  String likeliness() {
    String result = "error";
    switch (forecast_yr.findIssMatch()) {
      case 1:
      case 2:
        result = "Likely visible";
        break;
      case 3:
      case 41:
      case 25:
      case 43:
      case 27:
      case 45:
      case 29:
      case 40:
      case 24:
      case 42:
      case 44:
      case 26:
      case 28:
      case 5:
      case 6:
      case 7:
      case 20:
      case 8:
      case 21:
        result = "Possibly visible";
        break;
      default:
       result = "Unlikely visible";
       break;
    }
    return result;
  }

  color timeLeftBackground() {
    color result = color(0);
    if (passes.size() > 0) {
      if (likeliness().equals("Likely visible") == true) {
        if (urgency() == 2) {
          result = color(30, 100, 200);
        }
        if (urgency() == 3) {
          result = color(60, 180, 110);
          if (int(millis() / 300) % 4 == 0) {
            result = color(0);
          }
        }
      } else if (likeliness().equals("Possibly visible") == true) {
        result = color(90, 80, 80);
      } else if (likeliness().equals("Unlikely visible") == true) {
        result = color(0);
      }
    } else {result = color(0);}
    return result;
  }

  public void run() {

    anim1.start();

    noStroke();

    if (counter < 3) {

      background(0);

      fill(anim1.animate(0, 255, 1000, 1700, "quinticBoth"), anim1.animate(0, 255, 1000, 1700, "quinticBoth"), 255);
      shape(iss_logo, 128, 176, 464, 316);
      fill(0);
      //fill(#ff0000); // for testing
      rect(128,176,32,anim1.animate(176, 0, 0, 1700, "quinticBoth"));
      rect(160,224,anim1.animate(436, 0, 50, 1700, "quinticBoth"),48);
      rect(596,272,anim1.animate(-436, 0, 100, 1700, "quinticBoth"),33);
      rect(160,305,anim1.animate(436, 0, 150, 1700, "quinticBoth"),48);
      rect(128,493,370,anim1.animate(-125, 0, 1000, 1700, "quinticBoth"));

    } else if (counter < 5) {

      background(
        anim1.animate(0, red(timeLeftBackground()), 3000, 1000, "quinticBoth"),
        anim1.animate(0, green(timeLeftBackground()), 3000, 1000, "quinticBoth"),
        anim1.animate(0, blue(timeLeftBackground()), 3000, 1000, "quinticBoth")
        );

      fill(255);
      shape(iss_logo,
        anim1.animate(128, os_left + 32, 3000, 1000, "quinticBoth"),
        anim1.animate(176, 150, 3000, 1000, "quinticBoth"),
        anim1.animate(464, 464/2, 3000, 1000, "quinticBoth"),
        anim1.animate(316, 316/2, 3000, 1000, "quinticBoth")
      );

      vid_iss.display_dot_scan(int(anim1.animate(width, 340, 3000, 1000, "quinticBoth")), 110);

    } else {

      background(timeLeftBackground());

      fill(255);
      shape(iss_logo, os_left + 32, 150, 464/2, 316/2);

      textAlign(LEFT);
      textFont(bungee_regular);
      textSize(16);

      if (reachable) {
        if ( passes.size() > 0 && current_time.compareTo(next_sighting) < 0 ) {
          text("Next sighting",                                     os_left + 32, height - 230);
          text(getData(current_sighting_no, "Date"),                os_left + 32, height - 190);
          text(getData(current_sighting_no, "Time"),                os_left + 32, height - 170);
          text(getData(current_sighting_no, "Duration"),            os_left + 32, height - 150);
          text(getData(current_sighting_no, "Maximum Elevation"),   os_left + 32, height - 130);
          text(getData(current_sighting_no, "Approach"),            os_left + 32, height - 110);
          text(getData(current_sighting_no, "Departure"),           os_left + 32, height - 90);
          text("Condition: " + condition,                           os_left + 32, height - 70);
          text(getData(current_sighting_no, "Magnitude"),           os_left + 32, height - 50);
          textSize(24);
          text(timeLeft(),                                          os_left + 32, 100);
          if ( (urgency() == 2 && int(millis() / 500) % 4 != 0) || (urgency() == 3 && int(millis() / 300) % 4 != 0) )  {
            text(likeliness(),                                      os_left + 32, 125);
          }
        } else {
          text("No sightings for some time now.",                   os_left + 32, height - 230);
        }
      } else {
          text("No connection.",                                    os_left + 32, height - 230);
      }

      vid_iss.display_dot_scan(340, 110);

    }

  }

}
