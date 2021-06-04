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
    if (last_update != hour()) {

      reachable = checkConnection();

      if (reachable) {
        //iss_data = loadXML(URL).getChild("channel");
        iss_data = loadXML("iss_data_placeholder.xml").getChild("channel"); // test
        last_update = hour();
      } else {
        //////////// TODO make better placeholders here and for weather ///////////
        iss_data = loadXML("iss_data_placeholder.xml").getChild("channel");
        println("ISS - no connection");
      }
    }
    sightings = iss_data.getChildren("item");
    next_sighting = parseData(0);
    //condition = forecast_yr.findIssMatch();
    //println("test " + condition);
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

    int corrected_hour = int(getData(index, "Time").substring(6,8));
    if (getData(index, "Time").substring(12,14).equals("PM")) {
      corrected_hour += 12;
    }
    if (corrected_hour == 24) { corrected_hour = 0; }

    LocalDateTime parsed_date = LocalDateTime.of(
      int(getData(index, "raw_date").substring(0,4)),
      int(getData(index, "raw_date").substring(5,7)),
      int(getData(index, "raw_date").substring(8,10)),
      corrected_hour,
      int(getData(index, "Time").substring(9,11))
    );

    println("parsetest !!! "+parsed_date);
    return parsed_date;
  }

  public void run() {
      textFont(aspace_thin);
      textSize(80);
      text("ISS",                             64, height - 250);
      textFont(bungee_regular);
      textSize(18);
    if (sightings.length > 0) {
      text("Next sighting",                   64, height - 200);
      text(getData(0, "Date"),                64, height - 160);
      text(getData(0, "Time"),                64, height - 140);
      text(getData(0, "Duration"),            64, height - 120);
      text(getData(0, "Maximum Elevation"),   64, height - 100);
      text(getData(0, "Approach"),            64, height - 80);
      text(getData(0, "Departure"),           64, height - 60);
      text(condition,  64, height - 40);
    } else {
      text("No sightings for some time now.", 64, height - 200);
    }
  }

}
