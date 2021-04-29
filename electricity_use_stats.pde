
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import javax.net.ssl.HttpsURLConnection;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

 class ElectricityStats {

  private List<String> cookies;
  private HttpsURLConnection conn;

  private final String USER_AGENT = "Mozilla/5.0";

  public  ElectricityStats() {

    String url = "https://www.energiaonline.fi/Home/Index";
    String stats = "https://www.energiaonline.fi/EnergyReporting/EnergyReporting";

    // make sure cookies is turn on
    CookieHandler.setDefault(new CookieManager());

    // load credentials
    String[] user_pass = loadStrings("data/userpass.txt");

    // 1. Send a "GET" request, so that you can extract the form's data.
    String page = GetPageContent(url);
    String postParams = getFormParams(page, user_pass[0], user_pass[1]);

    // 2. Construct above post's content and then send a POST request for
    // authentication
    sendPost(url, postParams);

    // 3. success then go to stats.
    String result = GetPageContent(stats);
    //println(result);

  }

  private void sendPost(String url, String postParams) {
    try {
        URL obj = new URL(url);
        conn = (HttpsURLConnection) obj.openConnection();

    // Acts like a browser
    conn.setUseCaches(false);
    conn.setRequestMethod("POST");
    conn.setRequestProperty("Host", "accounts.google.com");
    conn.setRequestProperty("User-Agent", USER_AGENT);
    conn.setRequestProperty("Accept",
        "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
    conn.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
    for (String cookie : this.cookies) {
        conn.addRequestProperty("Cookie", cookie.split(";", 1)[0]);
    }
    conn.setRequestProperty("Connection", "keep-alive");
    conn.setRequestProperty("Referer", "https://accounts.google.com/ServiceLoginAuth");
    conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
    conn.setRequestProperty("Content-Length", Integer.toString(postParams.length()));

    conn.setDoOutput(true);
    conn.setDoInput(true);

    // Send post request
    DataOutputStream wr = new DataOutputStream(conn.getOutputStream());
    wr.writeBytes(postParams);
    wr.flush();
    wr.close();

    int responseCode = conn.getResponseCode();
    println("\nSending 'POST' request to URL : " + url);
    println("Post parameters : " + postParams);
    println("Response Code : " + responseCode);

    BufferedReader in =
             new BufferedReader(new InputStreamReader(conn.getInputStream()));
    String inputLine;
    StringBuffer response = new StringBuffer();

    while ((inputLine = in.readLine()) != null) {
        response.append(inputLine);
    }



    in.close();
    // println(response.toString());

    } catch (IOException exception) {println("some wtf error");}

  }

  private String GetPageContent(String url) {

    try {
    URL obj = new URL(url);
    conn = (HttpsURLConnection) obj.openConnection();

    // default is GET
    conn.setRequestMethod("GET");

    conn.setUseCaches(false);

    // act like a browser
    conn.setRequestProperty("User-Agent", USER_AGENT);
    conn.setRequestProperty("Accept",
        "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
    conn.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
    if (cookies != null) {
        for (String cookie : this.cookies) {
            conn.addRequestProperty("Cookie", cookie.split(";", 1)[0]);
        }
    }
    int responseCode = conn.getResponseCode();
    println("\nSending 'GET' request to URL : " + url);
    println("Response Code : " + responseCode);

    BufferedReader in =
            new BufferedReader(new InputStreamReader(conn.getInputStream()));
    String inputLine;
    StringBuffer response = new StringBuffer();

    while ((inputLine = in.readLine()) != null) {
        response.append(inputLine);
    }
    in.close();

    // Get the response cookies
    setCookies(conn.getHeaderFields().get("Set-Cookie"));

    return response.toString();

    } catch (IOException exception) {println("some wtf error"); return "wtf";}

  }

  public String getFormParams(String html, String username, String password) {

    println("Extracting form's data...");

    Document doc = Jsoup.parse(html);

    // Google form id
    Element loginform = doc.getElementById("LoginForm");
    Elements inputElements = loginform.getElementsByTag("input");
    List<String> paramList = new ArrayList<String>();
    for (Element inputElement : inputElements) {
        String key = inputElement.attr("name");
        String value = inputElement.attr("value");

        if (key.equals("UserName"))
            value = username;
        else if (key.equals("Password"))
            value = password;

        try {
            paramList.add(key + "=" + URLEncoder.encode(value, "UTF-8"));
        } catch (UnsupportedEncodingException e) {println("some wtf error");}
    }

    // build parameters list
    StringBuilder result = new StringBuilder();
    for (String param : paramList) {
        if (result.length() == 0) {
            result.append(param);
        } else {
            result.append("&" + param);
        }
    }
    return result.toString();

  }

  public List<String> getCookies() {
    return cookies;
  }

  public void setCookies(List<String> cookies) {
    this.cookies = cookies;
  }

}