// ISS tracker

class IssTracker {

  private XML iss_data;
  private XML[] sightings;
  private boolean reachable;
  private final static String URL = "https://spotthestation.nasa.gov/sightings/xml_files/Finland_None_Turku.xml";
  private final static int TIMEOUT = 5000;
  public float anim_phase;
  int last_update = 99;

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
        iss_data = loadXML(URL).getChild("channel");
        last_update = hour();
      } else {
        //////////// TODO make better placeholders here and for weather ///////////
        iss_data = loadXML("forecast_data_placeholder.xml");
        println("ISS - no connection");
      }
    }
    sightings = iss_data.getChildren("item");
  }

  String getData(int sighting_no, String input) {
    String data = sightings[sighting_no].getChild("description").getContent().substring(
      sightings[sighting_no].getChild("description").getContent().indexOf(input) /*+ input.length() + 2*/,
      sightings[sighting_no].getChild("description").getContent().indexOf("<br/>", sightings[sighting_no].getChild("description").getContent().indexOf(input))
      );
    return data;
  }

  public void run() {
    if (sightings.length > 0) {

      textFont(aspace_thin);
      textSize(80);
      text("ISS",                           64, height - 250);
      textFont(bungee_regular);
      textSize(18);
      text("Next sighting",                 64, height - 200);
      text(getData(0, "Date"),              64, height - 160);
      text(getData(0, "Time"),              64, height - 140);
      text(getData(0, "Duration"),          64, height - 120);
      text(getData(0, "Maximum Elevation"), 64, height - 100);
      text(getData(0, "Approach"),          64, height - 80);
      text(getData(0, "Departure"),         64, height - 60);


    }
  }

}
