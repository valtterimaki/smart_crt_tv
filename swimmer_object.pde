// Fishy particle. Copied and modified from processing.org


class ObjSwimmer {

// the nodes are stored here, amount is set to 5
PVector[] nodes;
// length between nodes
float segLength;
// location & direction
PVector location, direction;

  ObjSwimmer (float pos_x, float pos_y, float dir_x, float dir_y, float seg) {
    location = new PVector(pos_x, pos_y);
    direction = new PVector(dir_x, dir_y);
    segLength = seg;
    nodes = new PVector[5];

    // fill nodes with 0's in the start
    for (int i = 0; i < nodes.length; ++i) {
      nodes[i] = new PVector();
    }
  }

  void update() {

    stroke(255);

    dragSegment(0, location.x, location.y);

    for(int i=0; i<nodes.length-1; i++) {
      dragSegment(i+1, nodes[i].x, nodes[i].y);
    }

    direction.normalize();
    location.add(direction);

    direction.add(PVector.div(PVector.random2D(), 10));

  }

  void dragSegment(int i, float xin, float yin) {
    float dx = xin - nodes[i].x;
    float dy = yin - nodes[i].y;
    float angle = atan2(dy, dx);
    nodes[i].x = xin - cos(angle) * segLength;
    nodes[i].y = yin - sin(angle) * segLength;
    segment(nodes[i].x, nodes[i].y, angle);
  }

  void segment(float x, float y, float a) {
    pushMatrix();
    translate(x, y);
    rotate(a);
    line(0, 0, segLength, 0);
    popMatrix();
  }

}



