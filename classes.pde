// basic static noise image distortion effect

class ObjFx {

  // variables
  float vert_noise_pos = 200;
  float vert_noise_width = 7;
  float vert_noise_amp;

  ObjFx () {

  }

  void verticalNoise(float stren, boolean wav) {

    int distortion_min = 2;
    int distortion_max = int(Ease.quinticIn(noise(float(millis())/1000))*100) + 6;
    int intensity = int(Ease.quinticIn(noise(float(millis())/1000))*stren/2)+1;

    vert_noise_amp = random(6, 8);

    if (vert_noise_pos < height + vert_noise_width) {
      vert_noise_pos++;
    } else {
      vert_noise_pos = -vert_noise_width;
    }

    loadPixels();
    for (int i = 0; i < height; ++i) {
      if (i > vert_noise_pos - vert_noise_width && i < vert_noise_pos + vert_noise_width && wav == true) {
        for (int j = 0; j < width; ++j) {
          if (i < height - 1) {
            pixels[(i*width+j)] = pixels[(i*width+j+int(mapEased(i, vert_noise_pos - vert_noise_width, vert_noise_pos + vert_noise_width, 0, vert_noise_amp, "cubicIn", true)))];
          }
        }
      }
      if (int(random(1000)) <= intensity) {
        for (int j = 0; j < width; ++j) {
          if (i < height - 1) {
            pixels[(i*width+j)] = pixels[(i*width+j+int(Ease.quinticIn(random(0,1)) * (distortion_max - distortion_min) + distortion_min ))];
          }
        }
      }
    }
    updatePixels();
  }

}


// Animator

class Animator {

  // variables
  float start, phase;
  boolean is_started;

  Animator () {
    is_started = false;
  }

  void reset() {
    is_started = false;
  }

  void start() {
    if (is_started == false) {
      start = millis()-1;
      is_started = true;
    }
  }

  float getPhase(int offset, int duration, String easing) {
    phase = constrain(map(millis(), start + offset, start + duration + offset, 0, 1), 0, 1);
    float result = 0;

    if (is_started == true) {
      switch (easing) {
        case "linear":
          result = phase;
          break;
        case "quinticBoth":
          result = Ease.quinticBoth(phase);
          break;
        case "quinticIn":
          result = Ease.quinticIn(phase);
          break;
        case "quinticOut":
          result = Ease.quinticOut(phase);
          break;
        case "cubicBoth":
          result = Ease.cubicBoth(phase);
          break;
        case "cubicIn":
          result = Ease.cubicIn(phase);
          break;
        case "cubicOut":
          result = Ease.cubicOut(phase);
          break;
        case "elasticIn":
          result = Ease.elasticIn(phase);
          break;
        case "elasticOut":
          result = Ease.elasticOut(phase);
          break;
        case "quarticBoth":
          result = Ease.quarticBoth(phase);
          break;
        case "quarticIn":
          result = Ease.quarticIn(phase);
          break;
        case "quarticOut":
          result = Ease.quarticOut(phase);
          break;
        case "sinBoth":
          result = Ease.sinBoth(phase);
          break;
        case "sinIn":
          result = Ease.sinIn(phase);
          break;
        case "sinOut":
          result = Ease.sinOut(phase);
          break;
        case "bounceIn":
          result = Ease.bounceIn(phase);
          break;
        case "bounceOut":
          result = Ease.bounceOut(phase);
          break;
      }
    } else {
      result = 0;
    }

    return result;

  }

  float animate(float a, float b, int o, int d, String easing) {
    return lerp(a, b, getPhase(o, d, easing));
  }

}