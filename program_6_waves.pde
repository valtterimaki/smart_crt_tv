
// Renders an animated wave field using a 2D grid of vertices displaced by
// Perlin noise. Each column of grid points is drawn as a continuous open
// polyline, and the stroke colour/weight also varies with noise to give the
// lines an organic, flowing appearance.

class WaveSystem {

  // Number of grid columns (horizontal point count)
  int density_x;
  // Number of grid rows (vertical point count)
  int density_y;
  // Flat array storing the base (rest) position of every grid point
  PVector[] grid;
  // Half-cell offset so points are centred within each grid cell
  PVector offset;

  // How quickly noise values change across adjacent grid points (lower = smoother waves)
  float noise_scale = 0.08;
  // Maximum horizontal displacement applied to each vertex by noise
  float noise_amp_x = 100;
  // Maximum vertical displacement applied to each vertex by noise
  float noise_amp_y = 40;
  // Animated time offset fed into the noise function – advances each frame to
  // create motion; seeded randomly so each instance starts at a different phase
  float phase_one = random(1000);
  // Fixed rotation angle applied to the entire wave field (set randomly in setup)
  float rotation;
  // Reused scratch variable to avoid allocating per vertex in the draw loop
  float noise_val;

  // Constructor: builds the flat grid array.
  // d_x / d_y set how many columns and rows of points make up the wave field.
  WaveSystem(int d_x, int d_y) {
    density_x = d_x;
    density_y = d_y;
    grid = new PVector[density_x * density_y];
    // Half-cell inset so the outermost points sit at the centre of their cells
    offset = new PVector((width/float(density_x))/2, (height/float(density_y))/2);
    //offset = new PVector(30,30);

    // Populate the grid with evenly-spaced rest positions, centred around (0,0)
    // so the later translate(width/2, height/2) puts the field in the middle of
    // the canvas.
    for (int c = 0; c < density_x; ++c) {
      for (int r = 0; r < density_y; ++r) {
        grid[(c * density_y) + r] = new PVector(((width / float(density_x)) * c) + offset.x - width/2, ((width / float(density_y)) * r) + offset.y - width/2);
      }
    }
  }

  // One-time initialisation: configure Perlin noise detail, re-seed the phase,
  // and pick a random tilt so the wave field isn't always perfectly horizontal.
  void setup() {
    noiseDetail(4, 0.4); // 4 octaves, 0.4 persistence – fairly smooth noise
    phase_one = random(1000);
    rotation = random(-HALF_PI/2, HALF_PI/2); // tilt up to ±45°
  }

  // Called every frame from the main draw loop.
  // Advances the animation phase and triggers a redraw.
  void run() {
    phase_one += 0.005; // slow, continuous scroll through noise space
    draw();
  }

  // Renders the wave field for the current frame.
  void draw() {
    noFill();
    strokeWeight(1.2);
    stroke(255);

    // Centre, rotate, and scale the coordinate system so the field fills the
    // canvas with a slight zoom and the chosen random tilt.
    pushMatrix();
    translate(width/2, height/2);
    rotate(rotation);
    scale(1.3);

    // Draw one polyline per column; each row point within the column is
    // displaced by noise to produce the wave shape.
    for (int c = 0; c < density_x; ++c) {
      beginShape();
      for (int r = 0; r < density_y; ++r) {
        // Primary noise value drives horizontal displacement and stroke weight
        noise_val = noise(c*noise_scale*1.5+phase_one, r*noise_scale, phase_one);

        // Colour: sample three slightly offset noise coordinates for R, G, B so
        // the hue shifts organically across the field over time
        stroke(
          map(noise(c*noise_scale+phase_one, r*noise_scale, phase_one+1),   0, 0.6, 0, 255),
          map(noise(c*noise_scale+phase_one, r*noise_scale, phase_one-1),   0, 0.6, 0, 255),
          map(noise(c*noise_scale+phase_one, r*noise_scale, phase_one*1.1), 0, 0.6, 0, 255)
        );

        // Stroke weight varies with noise so lines appear thicker/thinner along
        // their length, reinforcing the organic feel
        strokeWeight((1 - noise_val - 0.5)*2.4+0.5);

        // Final vertex position:
        //   x – base position + a cubic-eased noise displacement for smooth
        //       horizontal rippling (cerp maps noise_val through a cubic curve,
        //       then Ease.cubicOut softens the acceleration)
        //   y – base position + a raw noise displacement for vertical undulation
        vertex(
          grid[(c * density_y) + r].x - noise_amp_x/2 + Ease.cubicOut(cerp(0, 0.7, 0.6, 0, noise_val))*noise_amp_x,
          grid[(c * density_y) + r].y - noise_amp_y/2 + noise(c*noise_scale+phase_one, r*noise_scale, phase_one)*noise_amp_y
        );
      }
      endShape();
    }

    // Debug visualisation of raw grid points (disabled)
    /*for (int i = 0; i < grid.length; ++i) {
      point(grid[i].x, grid[i].y);
    }*/

    popMatrix();
  }

}
