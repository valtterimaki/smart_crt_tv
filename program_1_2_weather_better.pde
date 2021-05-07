import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Date;

/*
FMI weather xml fetcher
By Fossa
 */

class WeatherNew {

  private XML root;
  private boolean reachable;
  private final static String  URL = "http://opendata.fmi.fi/wfs?service=WFS&version=2.0.0&request=getFeature&storedquery_id=fmi::forecast::hirlam::surface::point::simple&place=turku&parameters=temperature&";
  private final static int TIMEOUT = 5000;

  public WeatherNew() {
    reachable = checkConnection();
    println("connection: " + reachable);

    if (reachable) {
      root = loadXML(URL);
    } else {
      root = loadXML("weather_data_placeholder.xml");
      println("No connection");
    }
  }

  /*
   * General methods
   */
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

  public void update() {
    reachable = checkConnection();

    if (reachable) {
      root = loadXML(URL);
    } else {
      root = loadXML("weather_data_placeholder.xml");
      println("No connection");
    }
  }

  public String lastUpdate(){
    Date date = new Date();
    return date.toString();
  }


  /* Current weather & Basics */

  public String getTemperature() {
    return root.getChild("city").getString("name");
  }

/*
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
    return root.getChild("pressure").getInt("value"); //unit?
  }

  public int getHumidity() {
    return root.getChild("humidity").getInt("value"); //unit?
  }

  public float getTemperature() {
    return root.getChild("temperature").getFloat("value"); //unit?
  }

  public float getTemperatureMin() {
    return root.getChild("temperature").getFloat("min"); //unit?
  }

  public float getTemperatureMax() {
    return root.getChild("temperature").getFloat("max"); //unit?
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
  */

  /*

  public String getWeekday() {
    return channel.getChild("item").getChild(15).getString("day");
  }
  */

  /*
   * Tomorrow
   */
   /*
  public int getTemperatureLowTomorrow() {
    return channel.getChild("item").getChild(17).getInt("low");
  }

  public int getTemperatureHighTomorrow() {
    return channel.getChild("item").getChild(17).getInt("high");
  }


  public String getWeatherConditionTomorrow() {
    return channel.getChild("item").getChild(17).getString("text");
  }

  public int getWeatherConditionCodeTomorrow(){
    return channel.getChild("item").getChild(17).getInt("code");
  }


  public String getWeekdayTomorrow() {
    return channel.getChild("item").getChild(17).getString("day");
  }
  */
  /*
   * Day After Tomorrow
   *//*
  public int getTemperatureLowDayAfterTomorrow() {
    return channel.getChild("item").getChild(19).getInt("low");
  }

  public int getTemperatureHighDayAfterTomorrow() {
    return channel.getChild("item").getChild(19).getInt("high");
  }


  public String getWeatherConditionDayAfterTomorrow() {
    return channel.getChild("item").getChild(19).getString("text");
  }

  public int getWeatherConditionCodeDayAfterTomorrow(){
    return channel.getChild("item").getChild(19).getInt("code");
  }


  public String getWeekdayDayAfterTomorrow() {
    return channel.getChild("item").getChild(19).getString("day");
  }
*/
}
