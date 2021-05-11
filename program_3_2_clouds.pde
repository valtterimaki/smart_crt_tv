
// Particle system for cloud objects

class CloudSystem {

  ArrayList<ObjCloud> clouds;

  CloudSystem() {
    clouds = new ArrayList<ObjCloud>();
  }

  void setup() {
    for (int i = 0; i <= 5; ++i) {
      clouds.add(new ObjCloud(random(-100, width-100), random(10, 200)));
    }
  }

  void run() {
    for (int i = clouds.size()-1; i >= 0; i--) {
      ObjCloud s = clouds.get(i);
      s.update();

      if (program_number != 3) {
        clouds.remove(i);
      }
    }
    textFont(bungee_regular);
    textSize(24);
    textAlign(CENTER);
    if (counter % 2 == 0) {
      text("PILVISTÄ", width/2, height - 56);
    }
  }
}

// cloud object.

class ObjCloud {

  float x_pos;
  float y_pos;
  float z_pos;
  float x_dim;
  float y_dim;
  int local_counter;

  ObjCloud (float x, float y) {
    x_pos = x;
    y_pos = y;
    z_pos = random(1, 30);
    x_dim = int(random(40,160));
    y_dim = int(x_dim*random(0.1, 0.3));
    local_counter = counter;
  }

  void update() {
    //if ( counter != local_counter ){
      x_pos += z_pos/80;
      //local_counter = counter;
    //}
    draw();
  }

  void draw() {
    noStroke();
    fill(255);
    cloudShape(x_pos, y_pos, x_dim, y_dim);
    stroke(100);
    strokeWeight(1.5);
    noFill();
    cloudShadow(x_pos-z_pos*4, 350+z_pos*2, x_dim, y_dim/3);
  }

}
