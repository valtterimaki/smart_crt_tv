
// particle system for raindrop objects

class RainSystem {
  ArrayList<ObjRaindrop> raindrops;
  ObjLightning lightning;
  char condition_type;

  RainSystem() {
    raindrops = new ArrayList<ObjRaindrop>();
    lightning = new ObjLightning();
  }

  void addParticle() {
    raindrops.add(new ObjRaindrop(random(-100, width + 200), (pow(random(0, 1), 3) * (height/3)), 0, 0));
  }

  void run() {
    for (int i = raindrops.size()-1; i >= 0; i--) {
      ObjRaindrop r = raindrops.get(i);
      r.update();

      if (program_number != 4) {
        raindrops.remove(i);
      }

      else if (r.location.y > height + 100) {
        raindrops.remove(i);
        raindrops.add(new ObjRaindrop(random(-200, width + 400), (pow(random(0, 1), 3) * (height/3)), 0, 0));
      }
    }

    // here (somewhere) the function to see if other particles nearby to grow mass
    for (int i = raindrops.size()-1; i >= 0; i--) {
      PVector v1 = new PVector();
      PVector v2 = new PVector();
      float merge_distance = 10;

      ObjRaindrop r1 = raindrops.get(i);
      v1 = r1.location;
      for (int k = i-1; k >= 0; k--) {
        ObjRaindrop r2 = raindrops.get(k);
        v2 = r2.location;

        if (v1.dist(v2) <= (merge_distance - (r1.mass * 2))) {

          if (r1.direction.mag() < r2.direction.mag()) {
            r1.direction = r2.direction;
          }

          r1.mass *= 1.2;
          raindrops.remove(k);

          addParticle();
        }
      }
    }

    // make lightnings if thunderstorm

    condition_type = str(weather.getWeatherConditionID()).charAt(0);

    if (condition_type == '2') {
      if (random(100) < 2) {
        lightning.reset();
      }
      // update lightning
      lightning.update();
    }
  }
}


// Raindrop object.

class ObjRaindrop {

  // location & direction
  PVector location, direction, gravity;
  float drag_factor, mass;

  ObjRaindrop (float pos_x, float pos_y, float dir_x, float dir_y) {
    location = new PVector(pos_x, pos_y);
    direction = new PVector(dir_x, dir_y);
    gravity = new PVector(0, 0);
    drag_factor = 0.9;
    mass = 1;
  }

  void update() {

    gravity.y = ( (pow(mass, 0.8) - 1) * (pow(direction.mag(), 1.1)) ) * 0.8;
    gravity.x = gravity.y * weather.getWindSpeed() / 20 +  (gravity.y * random(-0.1, 0.1));

    direction.add(gravity);
    direction.add(PVector.mult(PVector.random2D(), 0.1));

    // drag
    direction.mult(drag_factor);
    location.add(direction);

    draw();

  }

  // This draws the graphics for the object
  void draw() {

    float length_mult = 0.4;

    strokeWeight(sqrt(mass)*2 - 0.8);
    stroke(255);

    // use this if you want color
    /*stroke(
      constrain(map(direction.mag(), 0, 10, 255, 0), 50, 255),
      constrain(map(direction.mag(), 0, 30, 255, 0), 200, 255),
      255
      );
    */

    line(location.x + direction.x * length_mult,
         location.y + direction.y * length_mult,
         location.x - direction.x * length_mult,
         location.y - direction.y * length_mult);

    // keep the screen black for an additional 1 sec to run the simulation start hidden for a while to reduce motion artifacts
    if (counter < 1) {
        background(0);
    }

  }

}

// lightning object

class ObjLightning {

  int counter;
  int flashcounter;
  PVector[] path;
  int segment_length;
  float angle;


  ObjLightning () {
    path = new PVector[100];
    segment_length = 10;
    reset();
  }

  void reset() {
    counter = 0;
    flashcounter = 0;
    path[0] = new PVector(random(width), random(50,100));
    for (int i = 0; i < path.length - 1; ++i) {
      angle = random(-0.5, 0.5) + random(-0.2, 0.2);;
      path[i + 1] = new PVector(path[i].x + segment_length * sin(angle), path[i].y + segment_length * cos(angle));
    }
  }

  void update() {

    counter++;

    if (counter % 6 < 3 && counter < 12) {
      background(0);
      strokeWeight(3);
      stroke(255,255,100);
      for (int i = 0; i < path.length - 1; ++i) {
        line(path[i].x, path[i].y, path[i + 1].x, path[i + 1].y);
      }

    }

  }

}




