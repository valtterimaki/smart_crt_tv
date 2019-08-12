// particle system for snow objects

class SnowSystem {
  ArrayList<ObjSnow> snowflakes;

  SnowSystem() {
    snowflakes = new ArrayList<ObjSnow>();
  }

  void addParticle() {
    snowflakes.add(new ObjSnow(random(width), random(-230, height), 0, 0, 0));
  }

  void run() {
    for (int i = snowflakes.size()-1; i >= 0; i--) {
      ObjSnow s = snowflakes.get(i);
      s.update();

      if (program_number != 3) {
        snowflakes.remove(i);
      }
    }
  }
}


// Snowflake object.

class ObjSnow {

  // location & direction
  PVector location, direction, gravity, lift;
  float drag;

  ObjSnow (float pos_x, float pos_y, float dir_x, float dir_y, float spd) {
    location = new PVector(pos_x, pos_y);
    direction = new PVector(dir_x, dir_y);
    //speed = spd;
    gravity = new PVector(0, 0.5);
    lift = new PVector(0,0);
    drag = 0.9;
  }

  void update() {


    //direction.normalize();
    //direction.mult(speed);

    direction.add(gravity);
    direction.add(PVector.mult(PVector.random2D(), 0.9));

    // swaying
    lift.set(direction);
    lift.mult(direction.mag() * 0.05);
    lift.rotate(HALF_PI * signum(direction.x) * -1 );

    // only lift if going down
    //if (direction.y > 0) {
      direction.add(lift);
    //}

    // drag
    direction.mult(drag);

    location.add(direction);

    draw(location.x, location.y);

  }

  // This draws the graphics for the object
  void draw(float x, float y) {

    //noStroke();
    //fill(255);
    //ellipse(x, y, 3, 3);

    strokeWeight(2);
    stroke(255);
    line(location.x + direction.x * 1, location.y + direction.y * 1, location.x - direction.x * 1, location.y - direction.y * 1);
  }

}



