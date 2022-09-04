class ObjFlash{

  float increment = 0.01;
  float phase = 0;

  ObjFlash () {
  }

  void update() {

    if (phase < 1) {
      phase += increment;
    }
    else {
      phase = 0;

      programChange();
      //programChangeTest(3,8); // use this to test certain programs together for debugging
      //program_number = 6; // NOTE! Use this to force certain program for debugging

      program_started = true;

      // & reset counter
      counter = 0;
    }

    // Noise effect
    if (phase < random(0.4, 0.8)) {
      noise2.set("time", (millis() / 1000.0) % 100);
      noise2.set("amount", phase);
      shader(noise2);
      image(tex, 0, 0, width, height);
    } else {
      background(0);
      tex = get();
    }
  }
}
