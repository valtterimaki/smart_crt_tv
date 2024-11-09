class CoralSystem {
  ArrayList<ObjCoral> corals;
  int density = 16;

  CoralSystem() {
    corals = new ArrayList<ObjCoral>();
  }

  void addcorals() {
    int count = 0;
    for (int x = 0; x < width; x += density) {
      for (int y = 0; y < height; y += density) {
        corals.add(new ObjCoral(x+random(-density/2, density/2), y+random(-density/2, density/2), density)); 
        count++;
      }
    }

  }

  void run() {

    float xoff = 0.0; // Start xoff at 0
    int counter = 0;
    for (int x = 0; x < width; x += density) {
      xoff += density;   // Increment xoff 
      float yoff = 0.0;   // For every xoff, start yoff at 0
      for (int y = 0; y < height; y += density) {
        yoff += density; // Increment yoff

        FastNoiseLite.Vector3 wcoords = new FastNoiseLite.Vector3(xoff, yoff, noise_z);
        warp.DomainWarp(wcoords);

        float vect_x = fastnoise.GetNoise(wcoords.x, wcoords.y, wcoords.z);
        float vect_y = fastnoise.GetNoise(wcoords.x, wcoords.y, wcoords.z + 10000);
        float dark1 = norm(fastnoise.GetNoise(wcoords.x, wcoords.y, wcoords.z + 20040), -1, 1);
        float dark3 = norm(fastnoise.GetNoise(wcoords.x, wcoords.y, wcoords.z + 20000), -1, 1);
        float dark2 = norm(fastnoise.GetNoise(wcoords.x, wcoords.y, wcoords.z + 20010), -1, 1);
        fastnoise.SetFrequency(0.014);
        float flic = fastnoise.GetNoise(wcoords.x, wcoords.y, wcoords.z + 20010);
        fastnoise.SetFrequency(0.001);
        ObjCoral s = corals.get(counter);
        s.update(vect_x, vect_y, dark1, dark2, dark3, flic);
        counter++;
      }
    }
  }

  void clear() {
    int size = corals.size();
    for (int i = size-1; i >= 0; i--) {
      corals.remove(i);
    }
  }
}


class ObjCoral {

  // location & direction
  PVector location;
  PVector direction;
  PVector force;
  float rand = 0.2;
  int density;

  ObjCoral (float pos_x, float pos_y, int dens) {
    location = new PVector(pos_x, pos_y);
    force = new PVector(0, 0);
    direction = new PVector(0, 0);
    density = dens;
  }

  void update(float vx, float vy, float vd1, float vd2, float vd3, float flic) {

    force.x = vx + random(-rand, rand);
    force.y =vy + random(-rand, rand);
    direction.mult(0.98);
    direction.add(force);
    direction.limit(density*3);

    stroke(
      pow(vd1, 3) * 320 * (1 + pow(flic,2)), 
      pow(vd2, 3) * 255 * (1 + pow(flic,2)), 
      pow(vd3, 3) * 290,
      100
      );
    strokeWeight(3.9);
   
    line(location.x, location.y, 0, location.x + direction.x, location.y + direction.y, density);
    point(location.x + direction.x, location.y + direction.y, density);

  }

}