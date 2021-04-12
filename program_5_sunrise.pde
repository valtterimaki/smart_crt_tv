
// Draws a diagram which shows sunrise & sunset

void draw_sun_diagram() {

  //String sunrise = weather.getSunrise().substring(weather.getSunrise().indexOf("T") + 1);
  //String sunset = weather.getSunset().substring(weather.getSunset().indexOf("T") + 1);
  String sun_now = weather.getLastUpdate().substring(weather.getLastUpdate().indexOf("T") + 1);
  int timezone_offset =  int(weather.getTimezone()) / 60; // in minutes

  int sunrise_mins = get_sun_in_minutes("rise");
  int sunset_mins = get_sun_in_minutes("set");
  int sun_now_mins = hour() * 60 + minute();

  int sun_radius = 25;
  float arc_radius = 180;
  PVector origo = new PVector(width/2, height/2);
  PVector sunrise_pt = new PVector((cos(minsToRad(sunrise_mins)) * arc_radius + origo.x), (sin(minsToRad(sunrise_mins)) * arc_radius + origo.y));
  PVector sunset_pt = new PVector((cos(minsToRad(sunset_mins)) * arc_radius + origo.x), (sin(minsToRad(sunset_mins)) * arc_radius + origo.y));
  PVector sun_now_pt = new PVector((cos(minsToRad(sun_now_mins)) * arc_radius + origo.x), (sin(minsToRad(sun_now_mins)) * arc_radius + origo.y));

  stroke(255);
  strokeWeight(1);

  noFill();
  arc(origo.x, origo.y, arc_radius * 2, arc_radius * 2, minsToRad(sunrise_mins), minsToRad(sunset_mins));

  line(
    sunrise_pt.x - (sunset_pt.x - sunrise_pt.x),
    sunrise_pt.y - (sunset_pt.y - sunrise_pt.y),
    sunset_pt.x + (sunset_pt.x - sunrise_pt.x),
    sunset_pt.y + (sunset_pt.y - sunrise_pt.y)
  );

  stroke(0);
  strokeWeight(2);
  float sun_line_angle = random(PI);
  float sun_line_deviation = random(10);


  fill(0);
  noStroke();
  ellipse(sun_now_pt.x, sun_now_pt.y, 2 * sun_radius, 2 * sun_radius);

  strokeWeight(1.5);
  stroke(255);
  for (float i = -0.95; i <= 1; i = i + 0.16) {
    pushMatrix();
    translate(sun_now_pt.x, sun_now_pt.y);
    rotate(random(1.2,1.25));
    line(
      sun_radius * i,
      sin(acos(i)) * sun_radius,
      sun_radius * i,
      sin(acos(i) - PI) * sun_radius
      );
    popMatrix();
  }

  String sunrise_corr = str(sunrise_mins / 60) + ":" + nf(sunrise_mins % 60, 2);
  String sunset_corr = str(sunset_mins / 60) + ":" + nf(sunset_mins % 60, 2);
  String time_now = str(hour()) + ":" + nf(minute(), 2);

  fill(255);
  textFont(source_code_light);
  textSize(20);
  text(sunrise_corr, sunrise_pt.x + 16, sunrise_pt.y);
  text(sunset_corr, sunset_pt.x + 16, sunset_pt.y);
  text(time_now, sun_now_pt.x - 100, sun_now_pt.y + 8);

}

float minsToRad(int mins) {
  float scale_factor = TWO_PI / (24 * 60); // the factor to multiply the minutes to get corresponding radians
  return (mins * scale_factor) + HALF_PI; // add TWO_PI to make midnight bottom
}


// Function to just return correct sunrise / sunset numbers
// Use parameters "rise" or "set" for variant

int get_sun_in_minutes(String which) {

  int result = 0;
  int timezone_offset =  int(weather.getTimezone()) / 60; // in minutes

  if (which == "rise") {
    String sunrise = weather.getSunrise().substring(weather.getSunrise().indexOf("T") + 1);
    result = int(sunrise.substring(0, 2)) * 60 + int(sunrise.substring(3, 5)) + timezone_offset;
  }

  if (which == "set") {
    String sunset = weather.getSunset().substring(weather.getSunset().indexOf("T") + 1);
    result = int(sunset.substring(0, 2)) * 60 + int(sunset.substring(3, 5)) + timezone_offset;
  }

  return result;
}

String minutes_to_time(int mins) {
  return str(mins / 60) + ":" + nf(mins % 60, 2);
}



