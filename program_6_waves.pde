
//code for wave generator here

class WaveSystem {

  int density_x;
  int density_y;
  PVector[] grid;
  PVector offset;
  float noise_scale = 0.08;
  float noise_amp_x = 100;
  float noise_amp_y = 40;
  float phase_one = random(1000);
  float rotation;
  float noise_val;

  WaveSystem(int d_x, int d_y) {
    density_x = d_x;
    density_y = d_y;
    grid = new PVector[density_x * density_y];
    offset = new PVector((width/float(density_x))/2, (height/float(density_y))/2);
    //offset = new PVector(30,30);

    for (int c = 0; c < density_x; ++c) {
      for (int r = 0; r < density_y; ++r) {
        grid[(c * density_y) + r] = new PVector(((width / float(density_x)) * c) + offset.x - width/2, ((width / float(density_y)) * r) + offset.y - width/2);
      }
    }
  }

  void setup() {
    noiseDetail(4, 0.4);
    phase_one = random(1000);
    rotation = random(-HALF_PI/2,HALF_PI/2);
  }

  void run() {
    phase_one += 0.005;
    draw();
  }

  void draw() {
    noFill();
    strokeWeight(1.2);
    stroke(255);

    pushMatrix();
    translate(width/2, height/2);
    rotate(rotation);
    scale(1.3);

    for (int c = 0; c < density_x; ++c) {
      beginShape();
      for (int r = 0; r < density_y; ++r) {
        noise_val = noise(c*noise_scale*1.5+phase_one, r*noise_scale, phase_one);
        stroke(
          map(noise(c*noise_scale+phase_one,r*noise_scale, phase_one+1),    0, 0.6, 0, 255),
          map(noise(c*noise_scale+phase_one,r*noise_scale, phase_one-1),    0, 0.6, 0, 255),
          map(noise(c*noise_scale+phase_one,r*noise_scale, phase_one*1.1),  0, 0.6, 0, 255)
          );
        strokeWeight((1 - noise_val - 0.5)*2.4+0.5);
        vertex(
          grid[(c * density_y) + r].x - noise_amp_x/2 + Ease.cubicOut(cerp(0,0.7,0.6,0,noise_val))*noise_amp_x,
          grid[(c * density_y) + r].y - noise_amp_y/2 + noise(c*noise_scale+phase_one,r*noise_scale,phase_one)*noise_amp_y
        );
      }
      endShape();
    }

    /*for (int i = 0; i < grid.length; ++i) {
      point(grid[i].x, grid[i].y);
    }*/

    popMatrix();
  }

}
