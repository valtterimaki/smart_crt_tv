// particle system for snow objects

class SnowSystem {
  ArrayList<ObjSnow> snowflakes;

  SnowSystem() {
    snowflakes = new ArrayList<ObjSnow>();
  }

  void addParticle() {
    snowflakes.add(new ObjSnow(random(width), random(width), 0, 0, 0));
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

  ObjSnow (float pos_x, float pos_y, float dir_x, float dir_y, float spd) {
    location = new PVector(pos_x, pos_y);
    direction = new PVector(dir_x, dir_y);
    //speed = spd;
    gravity = new PVector(0, 0.5);
    lift = new PVector(0,0);
  }

  void update() {


    //direction.normalize();
    //direction.mult(speed);

    direction.add(gravity);
    direction.add(PVector.mult(PVector.random2D(), 0.2));

    // swaying
    lift.set(direction);
    lift.mult(direction.mag() * 0.1);
    lift.rotate(HALF_PI * signum(direction.x) * -1 );
    direction.add(lift);

    location.add(direction);

    draw(location.x, location.y);

  }

  // This draws the graphics for the object
  void draw(float x, float y) {

    noStroke();
    fill(30);
    ellipse(x, y, 10, 10);

    stroke(255,0,0);
    line(location.x, location.y, location.x + lift.x, location.y + lift.y);
  }

}



