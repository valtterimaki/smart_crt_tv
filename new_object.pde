// particle system for snow objects

class NewSystem {
  ArrayList<ObjNew> newobjects;

  NewSystem() {
    newobjects = new ArrayList<ObjNew>();
  }

  void addParticle() {
    newobjects.add(new ObjNew(random(width), random(width), random(-1,1), random(-1,1), random(4,5)));
  }

  void run() {
    for (int i = newobjects.size()-1; i >= 0; i--) {
      ObjNew s = newobjects.get(i);
      s.update();

      if (program_number != 3) {
        newobjects.remove(i);
      }

    }
  }
}


// Snowflake object.

class ObjNew {

  // location & direction
  PVector location, direction;
  // speed
  float speed;

  ObjNew (float pos_x, float pos_y, float dir_x, float dir_y, float spd) {
    location = new PVector(pos_x, pos_y);
    direction = new PVector(dir_x, dir_y);
    speed = spd;
  }

  void update() {

    direction.add(PVector.mult(PVector.random2D(), 0.5));
    direction.normalize();
    direction.mult(speed);
    speed *= (0.98 + random(-0.01, 0.01));

    location.add(direction);

    if (speed <= 0.6) {
      speed = 5;
    }

    draw(location.x, location.y);

  }

  // This draws the graphics for the object
  void draw(float x, float y) {

    fill(255);
    ellipse(x, y, 10, 10);

  }

}
