// particle system for snow objects

class SunSystem {
  ArrayList<ObjSunRay> rays;
  PVector origo;
  int radius, step, gap, offset;

  SunSystem() {
    rays = new ArrayList<ObjSunRay>();
    origo = new PVector(width/2, height/2);
    radius = 128;
    step = 10;
    gap = 4;
    offset = 2;
  }

  PVector rayposition(int number, String startend) {
    PVector result = new PVector();

    if (startend == "start") {
      result.set(
        origo.x - sqrt(sq(radius)-sq(step*number-radius + offset)),
        origo.y - radius + step*number - step + offset
        );
    }

    if (startend == "end") {
      result.set(
        origo.x + sqrt(sq(radius)-sq(step*number-radius + offset)),
        origo.y - radius + step*number - gap + offset
        );
    }
    return result;
  }

  void setup() {
    for (int i = 0; i <= ((radius*2 - offset) / step); ++i) {
      rays.add(new ObjSunRay(rayposition(i, "start").x, rayposition(i, "start").y, rayposition(i, "end").x, rayposition(i, "end").y, i));
    }
  }

  void run() {
    for (int i = rays.size()-1; i >= 0; i--) {
      ObjSunRay s = rays.get(i);
      s.update();

      if (program_number != 9) {
        rays.remove(i);
      }

    }
  }
}


// Snowflake object.

class ObjSunRay {

  // start and end points
  PVector startpoint, endpoint;
  PVector start_draw, end_draw;
  float order;
  float time;

  ObjSunRay (float start_x, float start_y, float end_x, float end_y, int id) {
    startpoint = new PVector(start_x, start_y);
    endpoint = new PVector(end_x, end_y);
    start_draw = new PVector(start_x, start_y);
    end_draw = new PVector(end_x, end_y);
    order = id;
    time = 0;
  }

  void update() {
    time += 0.02;
    noiseDetail(4, 0.8);
    float wobble = (noise(order, time) -0.5) * (sq(order) /20 +8);
    println(startpoint.x);
    start_draw.x = startpoint.x + wobble;
    end_draw.x = endpoint.x + wobble;
    draw();
  }

  // This draws the graphics for the object
  void draw() {
    fill(255,230,150);
    cloudShape(start_draw.x, start_draw.y, end_draw.x - start_draw.x, end_draw.y - start_draw.y);
  }

}
