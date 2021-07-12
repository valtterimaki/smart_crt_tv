// ISS tracker

class IssTracker {

  private XML iss_data;
  private XML[] sightings;
  private boolean reachable;
  private final static String URL = "https://spotthestation.nasa.gov/sightings/xml_files/Finland_None_Turku.xml";
  private final static int TIMEOUT = 5000;
  public float anim_phase;
  int last_update = 99;
  String condition;
  LocalDateTime next_sighting;
  LocalDateTime current_time;
  int current_sighting_no;

  public IssTracker() {
    update();
    println("ISS last update: " + lastUpdate());
    anim_phase = 0;

  }

  /* General methods*/

  public boolean checkConnection() {
    try {
      HttpURLConnection connection = (HttpURLConnection) new URL(URL).openConnection();
      connection.setConnectTimeout(TIMEOUT);
      connection.setReadTimeout(TIMEOUT);
      int responseCode = connection.getResponseCode();
      println(responseCode);
      return (200 <= responseCode && responseCode <= 399);
    } catch (IOException exception) {
      return false;
    }
  }

  public String lastUpdate(){
    Date date = new Date();
    return date.toString();
  }

  public void update() {

    current_time = LocalDateTime.now();

    if (last_update != hour()) {

      reachable = checkConnection();

      if (reachable) {
        iss_data = loadXML(URL).getChild("channel");
        //iss_data = loadXML("iss_data_placeholder.xml").getChild("channel"); // test
        last_update = hour();
      } else {
        //////////// TODO make better placeholders here and for weather ///////////
        iss_data = loadXML("iss_data_placeholder.xml").getChild("channel");
        println("ISS - no connection");
      }
    }
    sightings = iss_data.getChildren("item");
    println("TESSSS" + current_time);
    for (int i = 0; i < sightings.length; ++i) {
      if (current_time.compareTo(parseData(i)) < 0 ) {
        current_sighting_no = i;
        break;
      }
    }
    next_sighting = parseData(current_sighting_no);
    println("DIFFERENCE days" + localDateTimeDiff(current_time, next_sighting, "d"));
    println("DIFFERENCE hrs" + localDateTimeDiff(current_time, next_sighting, "h"));
    println("DIFFERENCE mins" + localDateTimeDiff(current_time, next_sighting, "m"));
    forecast_yr.update();
  }

  String getData(int sighting_no, String input) {
    if (input.equals("raw_date")) {
      return sightings[sighting_no].getChild("title").getContent().substring(0, 10);
    }
    String data = sightings[sighting_no].getChild("description").getContent().substring(
      sightings[sighting_no].getChild("description").getContent().indexOf(input) /*+ input.length() + 2*/,
      sightings[sighting_no].getChild("description").getContent().indexOf("<br/>", sightings[sighting_no].getChild("description").getContent().indexOf(input))
      );
    return data;
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

    println("parsetest !!! "+parsed_date);
    return parsed_date;
  }

  String timeLeft() {
    String result = "error";

    if (localDateTimeDiff(current_time, next_sighting, "d") != 0) {
      result = "In about " + str(localDateTimeDiff(current_time, next_sighting, "d")) + " days";
    }
    if (localDateTimeDiff(current_time, next_sighting, "d") == 0 && localDateTimeDiff(current_time, next_sighting, "h") != 0) {
      result = "In " + nf(localDateTimeDiff(current_time, next_sighting, "h")) + " hours and " + nf(localDateTimeDiff(current_time, next_sighting, "m")) + " minutes";
    }
    if (localDateTimeDiff(current_time, next_sighting, "d") == 0 && localDateTimeDiff(current_time, next_sighting, "h") == 0) {
      result = "In " + nf(localDateTimeDiff(current_time, next_sighting, "m")) + " minutes";
    }

    return result;
  }

  color timeLeftBackground() {
    color result = color(0);

    if (localDateTimeDiff(current_time, next_sighting, "d") == 0 && localDateTimeDiff(current_time, next_sighting, "h") != 0) {
      result = color(30, 100, 200);
    }
    if (localDateTimeDiff(current_time, next_sighting, "d") == 0 && localDateTimeDiff(current_time, next_sighting, "h") == 0) {
      result = color(60, 180, 110);
    }

    return result;
  }

  public void run() {
      background(timeLeftBackground());
      textFont(aspace_thin);
      textSize(80);
      text("ISS",                                               64, height - 270);
      textFont(bungee_regular);
      textSize(14);
    if (sightings.length > 0) {
      text("Next sighting",                                     64, height - 220);
      text(getData(current_sighting_no, "Date"),                64, height - 180);
      text(getData(current_sighting_no, "Time"),                64, height - 160);
      text(getData(current_sighting_no, "Duration"),            64, height - 140);
      text(getData(current_sighting_no, "Maximum Elevation"),   64, height - 120);
      text(getData(current_sighting_no, "Approach"),            64, height - 100);
      text(getData(current_sighting_no, "Departure"),           64, height - 80);
      text(condition,                                           64, height - 60);
      textSize(24);
      text(timeLeft(),                                          64, 150);
    } else {
      text("No sightings for some time now.",                   64, height - 220);
    }
  }

}
