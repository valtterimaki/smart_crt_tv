// ISS tracker

class IssTracker {

  private volatile XML iss_data;
  private XML[] sightings;
  private volatile boolean reachable = false;
  private volatile boolean is_fetching = false;
  private final static String URL = "https://spotthestation.nasa.gov/sightings/xml_files/Finland_None_Turku.xml";
  public float anim_phase;
  int last_update = 99;
  String condition;
  LocalDateTime next_sighting;
  LocalDateTime current_time;
  int current_sighting_no;
  PShape iss_logo;
  Animator anim1 = new Animator();

  public IssTracker() {
    fetch(); // synchronous on setup – that's fine
    // Populate sighting index from initial data
    current_time = LocalDateTime.now();
    sightings = iss_data.getChildren("item");
    for (int i = 0; i < sightings.length; ++i) {
      if (current_time.compareTo(parseData(i)) < 0) { current_sighting_no = i; break; }
    }
    if (sightings.length > 0) next_sighting = parseData(current_sighting_no);
    else next_sighting = current_time;
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
      XML root = parseXML(fetchStringFromURL(URL));
      XML loaded = (root != null) ? root.getChild("channel") : null;
      if (loaded != null) {
        iss_data = loaded;
        reachable = true;
      } else {
        throw new Exception("No channel element");
      }
    } catch (Exception e) {
      reachable = false;
      iss_data = loadXML("iss_data_placeholder.xml").getChild("channel");
      println("ISS - fetch failed: " + e.getMessage());
    } finally {
      last_update = hour();
      is_fetching = false;
    }
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
    sightings = iss_data.getChildren("item");
    for (int i = 0; i < sightings.length; ++i) {
      if (current_time.compareTo(parseData(i)) < 0) { current_sighting_no = i; break; }
    }
    if (sightings.length > 0) next_sighting = parseData(current_sighting_no);
    else next_sighting = current_time;
    // forecast_yr is now updated independently in smart_crt_tv.pde
  }

  String getData(int sighting_no, String input) {
    try {
      if (input.equals("raw_date")) {
        return sightings[sighting_no].getChild("title").getContent().substring(0, 10);
      }
      String data = sightings[sighting_no].getChild("description").getContent().substring(
        sightings[sighting_no].getChild("description").getContent().indexOf(input) /*+ input.length() + 2*/,
        sightings[sighting_no].getChild("description").getContent().indexOf("<br/>", sightings[sighting_no].getChild("description").getContent().indexOf(input))
      );
      println(data);
      return data;
    } catch(ArrayIndexOutOfBoundsException e) {
      println("error in sighting number");
      //if error for debugging
      println(iss_data);
      String data = "Time: ee:ee AM ";
      return data;

    }
  }

  LocalDateTime parseData(int index) {

    int corrected_hour, corrected_minute;

    if (getData(index, "Time").substring(7,8).equals(":")) {
      corrected_hour = int(getData(index, "Time").substring(6,7));
      corrected_minute = int(getData(index, "Time").substring(8,10));
    } else {
      corrected_hour = int(getData(index, "Time").substring(6,8));
      corrected_minute = int(getData(index, "Time").substring(9,11));
    }

    if (getData(index, "Time").substring(12,14).equals("PM") || getData(index, "Time").substring(11,13).equals("PM")) {
      corrected_hour += 12;
    }
    else if (corrected_hour == 12) {
      corrected_hour = 0;
    }


    if (corrected_hour == 24) { corrected_hour = 0; }

    LocalDateTime parsed_date = LocalDateTime.of(
      int(getData(index, "raw_date").substring(0,4)),
      int(getData(index, "raw_date").substring(5,7)),
      int(getData(index, "raw_date").substring(8,10)),
      corrected_hour,
      corrected_minute
    );

    //println("parsetest !!! "+parsed_date);
    return parsed_date;
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
    if (sightings.length > 0) {
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
        if ( sightings.length > 0 && current_time.compareTo(next_sighting) < 0 ) {
          text("Next sighting",                                     os_left + 32, height - 230);
          text(getData(current_sighting_no, "Date"),                os_left + 32, height - 190);
          text(getData(current_sighting_no, "Time"),                os_left + 32, height - 170);
          text(getData(current_sighting_no, "Duration"),            os_left + 32, height - 150);
          text(getData(current_sighting_no, "Maximum Elevation"),   os_left + 32, height - 130);
          text(getData(current_sighting_no, "Approach"),            os_left + 32, height - 110);
          text(getData(current_sighting_no, "Departure"),           os_left + 32, height - 90);
          text("Condition: " + condition,                           os_left + 32, height - 70);
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
