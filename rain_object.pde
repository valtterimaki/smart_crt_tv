// particle system for raindrop objects

class RainSystem {
  ArrayList<ObjRaindrop> raindrops;

  RainSystem() {
    raindrops = new ArrayList<ObjRaindrop>();
  }

  void addParticle() {
    raindrops.add(new ObjRaindrop(random(width), random(0, height/4), 0, 0));
  }

  void run() {
    for (int i = raindrops.size()-1; i >= 0; i--) {
      ObjRaindrop r = raindrops.get(i);
      r.update();

      if (program_number != 4) {
        println(i);
        raindrops.remove(i);
      }
      
      else if (r.location.y > height + 100) {
        raindrops.remove(i);
      }
    }
    
    // here (somewhere) the function to see if other particles nearby to grow mass
    for (int i = raindrops.size()-1; i >= 0; i--) {
      PVector v1 = new PVector();
      PVector v2 = new PVector();
      int deletecount = 0;
      
      ObjRaindrop r1 = raindrops.get(i);
      v1 = r1.location;
      for (int k = i-1; k >= 0; k--) {
        ObjRaindrop r2 = raindrops.get(k);
        v2 = r2.location;
        
        if (v1.dist(v2) <= 3) {
          ObjRaindrop massed = raindrops.get(k);
          massed.mass *= 2;
          raindrops.remove(i-deletecount);
          deletecount++;
          
          addParticle();
        } 
      }
    }
  }
}


// Raindrop object.

class ObjRaindrop {

  // location & direction
  PVector location, direction, gravity;
  float drag, mass;

  ObjRaindrop (float pos_x, float pos_y, float dir_x, float dir_y) {
    location = new PVector(pos_x, pos_y);
    direction = new PVector(dir_x, dir_y);
    gravity = new PVector(0, 0);
    drag = 0.9;
    mass = 0.01;
  }

  void update() {

    gravity.y = mass * 2;
    
    direction.add(gravity);
    direction.add(PVector.mult(PVector.random2D(), 0.9));

    // drag
    direction.mult(drag);
    location.add(direction);

    draw();

  }

  // This draws the graphics for the object
  void draw() {

    //noStroke();
    //fill(255);
    //ellipse(x, y, 3, 3);

    strokeWeight(mass/5*2 +1);
    stroke(255);
    line(location.x + direction.x * 1, location.y + direction.y * 1, location.x - direction.x * 1, location.y - direction.y * 1);
  }

}
