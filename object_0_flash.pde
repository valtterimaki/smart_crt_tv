class ObjFlash{

  float xinit, yinit, increment;
  float phase = 0;
  float phase_eased, invph;
  float rnd;
  PVector a = new PVector();
  PVector b = new PVector();
  PVector c = new PVector();
  PVector d = new PVector();
  PVector target_a = new PVector(lerp(width*0.05, width*0.4, random(1)),lerp(height*0.4, height*0.6, random(1)));
  PVector target_b = new PVector(lerp(width*0.6, width*0.95, random(1)),lerp(height*0.4, height*0.6, random(1)));

  ObjFlash (float xd, float yd, float dr) {
    xinit = xd;
    yinit = yd;
    increment = 1/dr;
  }

  void update() {

    rnd = constrain(phase, 0, 0.2) * 3000;

    if (phase < 1) {

      phase_eased = Ease.quinticBoth(Ease.cubicOut(Ease.quarticOut(phase)));
      invph = 1 - phase_eased;

      a.set(lerp(0, target_a.x , phase_eased) + random(0,rnd)*invph, lerp(0, target_a.y , phase_eased) + random(0,rnd)*invph);
      b.set(lerp(width, target_b.x , phase_eased) + random(-rnd,0)*invph, lerp(0, target_b.y , phase_eased) + random(0,rnd)*invph);
      c.set(lerp(width, target_b.x , phase_eased) + random(-rnd,0)*invph, lerp(height, target_b.y , phase_eased) + random(-rnd,0)*invph);
      d.set(lerp(0, target_a.x , phase_eased) + random(0,rnd)*invph, lerp(height, target_a.y , phase_eased) + random(-rnd,0)*invph);

      phase += increment;

    }

    else {
      phase = 0;
      target_a.set(lerp(width*0.05, width*0.4, random(1)),lerp(height*0.4, height*0.6, random(1)));
      target_b.set(lerp(width*0.6, width*0.95, random(1)),lerp(height*0.4, height*0.6, random(1)));

      programChange();
      //programChangeTest(3,8); // use this to test certain programs together for debugging
      //program_number = 0; // NOTE! Use this to force certain program for debugging

      program_started = true;
      // & reset counter
      counter = 0;
    }

  }

  void display() {

    if (phase < 1) {

      // drawing the flash
      //fill(255, pow(phase, 2) * 20000);
      noStroke();
      fill(255);
      beginShape();
      vertex(a.x, a.y);
      vertex(b.x, b.y);
      vertex(c.x, c.y);
      vertex(d.x, d.y);
      endShape();
      noFill();
    }
  }
}
