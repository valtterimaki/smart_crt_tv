// particle system for swimmer objects

class SwimmerSystem {
  ArrayList<ObjSwimmer> swimmers;

  SwimmerSystem() {
    swimmers = new ArrayList<ObjSwimmer>();
  }

  void addParticle() {
    swimmers.add(new ObjSwimmer(random(width), random(width), random(-1,1), random(-1,1), random(10, 16), random(4,5)));
  }

  void run() {
    for (int i = swimmers.size()-1; i >= 0; i--) {
      ObjSwimmer s = swimmers.get(i);
      s.update();

      if (program_number != 2) {
        swimmers.remove(i);
      }

    }
  }
}


// Swimmer object. Copied and modified from processing.org

class ObjSwimmer {

  // the nodes are stored here, amount is set to 5
  PVector[] nodes;
  // length between nodes + speed
  float segLength, speed;
  // location & direction
  PVector location, direction;

  ObjSwimmer (float pos_x, float pos_y, float dir_x, float dir_y, float seg, float spd) {
    location = new PVector(pos_x, pos_y);
    direction = new PVector(dir_x, dir_y);
    segLength = seg;
    nodes = new PVector[6];
    speed = spd;

    // fill nodes with 0's in the start
    for (int i = 0; i < nodes.length; ++i) {
      nodes[i] = new PVector();
    }
  }

  void update() {

    stroke(255);
    strokeWeight(1);
    noFill();
    strokeCap(SQUARE);

    dragSegment(0, location.x, location.y);

    for(int i=0; i<nodes.length-1; i++) {
      dragSegment(i+1, nodes[i].x, nodes[i].y);
    }

    direction.add(PVector.mult(PVector.random2D(), 0.5));
    direction.normalize();
    direction.mult(speed);
    speed *= (0.98 + random(-0.02, 0.02));

    location.add(direction);

    if (speed <= (0.6 + random(0.1))) {
      speed = 5;
    }

    int buffer = 80;

    //looping over edges
    if (location.x < -buffer) {
      for(int i=0; i<nodes.length-1; i++) {
        nodes[i].x += width+buffer ;
      }
      location.x = width;
    }
    if (location.x > width+buffer) {
      for(int i=0; i<nodes.length-1; i++) {
        nodes[i].x -= width+buffer ;
      }
      location.x = 0;
    }
    if (location.y < -buffer) {
      for(int i=0; i<nodes.length-1; i++) {
        nodes[i].y += height+buffer ;
      }
      location.y = height;
    }
    if (location.y > height+buffer) {
      for(int i=0; i<nodes.length-1; i++) {
        nodes[i].y -= height+buffer ;
      }
      location.y = 0;
    }

  }

  // This updates the tail position
  void dragSegment(int i, float xin, float yin) {
    float dx = xin - nodes[i].x;
    float dy = yin - nodes[i].y;
    float angle = atan2(dy, dx);
    nodes[i].x = xin - cos(angle) * segLength;
    nodes[i].y = yin - sin(angle) * segLength;
    segment(nodes[i].x, nodes[i].y, angle, (16-(i*2)));
  }

  // This draws the graphics for the object
  void segment(float x, float y, float a, float s) {

    pushMatrix();
    translate(x, y);
    rotate(a);

    //line(0, 0, segLength/2, 0);
    ellipse(0, 0, s, s);
    line(0, 0, -segLength/2, 0);

    popMatrix();

  }

}
