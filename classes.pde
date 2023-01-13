
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


//public void movieEvent(Movie src_mov) {
//  src_mov.read();
//}


/*class ScanVideo {

  int cumul;
  int pos_x, pos_y;
  int thresh, thresh_min, thresh_max;
  int variance_speed;

  ScanVideo (int px, int py, int tmin, int tmax, int vspd) {
    pos_x = px;
    pos_y = py;
    thresh_min = tmin;
    thresh_max = tmax;
    variance_speed = vspd;
  }

  void updatePos(int px, int py) {
    pos_x = px;
    pos_y = py;
  }

  void run() {

    colorMode(HSB, 360, 100, 100);
    strokeWeight(1);
    thresh = int(map(noise(float(millis()) * (0.001 * variance_speed)), 0, 1, thresh_min, thresh_max));

    image(src_mov, width+1, height+1);

    src_mov.loadPixels();

    for (int y = 0; y < src_mov.height; ++y) {
      cumul = 0;

      for (int x = 0; x < src_mov.width; ++x) {
        color col = src_mov.pixels[y * src_mov.width + x];
        if(brightness(col) > 0) {
          cumul += brightness(col);
        }

        if (cumul >= thresh) {
          col = color(hue(col), map(saturation(col), 0, 100, 0, 100), 100);
          stroke(col);
          point(x + pos_x, y + pos_y);
          cumul = 0;
        }
      }
    }
    colorMode(RGB, 255, 255, 255);

    //src_mov.jump(0); // debug pause video

  }

}*/
