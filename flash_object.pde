
// Example object for later


class ObjFlash{

  float xinit, yinit, increment;
  float phase = 0;
  float phase_eased, invph;
  float rnd = 100;
  PVector a = new PVector();
  PVector b = new PVector();
  PVector c = new PVector();
  PVector d = new PVector();
  PVector target_a = new PVector(lerp(width*0.05, width*0.4, random(1)),lerp(height*0.3, height*0.7, random(1)));
  PVector target_b = new PVector(lerp(width*0.6, width*0.95, random(1)),lerp(height*0.3, height*0.7, random(1)));

  ObjFlash (float xd, float yd, float dr) {
    xinit = xd;
    yinit = yd;
    increment = 1/dr;
  }

  void update() {

    if (phase < 1) {

      phase_eased = Ease.cubicBoth(Ease.cubicOut(Ease.quinticOut(phase)));
      invph = 1 - phase_eased;

      a.set(lerp(0, target_a.x , phase_eased) + random(-rnd,rnd)*invph, lerp(0, target_a.y , phase_eased) + random(-rnd,rnd)*invph);
      b.set(lerp(width, target_b.x , phase_eased) + random(-rnd,rnd)*invph, lerp(0, target_b.y , phase_eased) + random(-rnd,rnd)*invph);
      c.set(lerp(width, target_b.x , phase_eased) + random(-rnd,rnd)*invph, lerp(height, target_b.y , phase_eased) + random(-rnd,rnd)*invph);
      d.set(lerp(0, target_a.x , phase_eased) + random(-rnd,rnd)*invph, lerp(height, target_a.y , phase_eased) + random(-rnd,rnd)*invph);

      phase += increment;

    }

    else {
      phase = 0;
      target_a.set(lerp(width*0.05, width*0.4, random(1)),lerp(height*0.3, height*0.7, random(1)));
      target_b.set(lerp(width*0.6, width*0.95, random(1)),lerp(height*0.3, height*0.7, random(1)));

      // When flash is over, set a new program
      program_number = 1; // This should be set later to randomize the program
      program_started = true;
      // & reset counter
      counter = 0;
    }

  }

  void display() {

    if (phase < 1) {

      // Drawing the shape
      noStroke();
      fill(255);

      beginShape();
      vertex(a.x, a.y);
      vertex(b.x, b.y);
      vertex(c.x, c.y);
      vertex(d.x, d.y);
      endShape(CLOSE);
    }
  }
}