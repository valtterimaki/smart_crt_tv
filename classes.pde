
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

// Class for animating a sequence of PNG's

class ImageSequence {
  PImage[] images;
  int imageCount;
  int frame;
  int thresh_min, thresh_max, variance_speed;
  
  ImageSequence(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = imagePrefix + nf(i, 4) + ".png";
      images[i] = loadImage(filename);
    }
  }

  void display(float xpos, float ypos) {
    frame = (frame+1) % imageCount;
    image(images[frame], xpos, ypos);
  }

  void dot_scan_settings(int t_min, int t_max, int v_spd) {
    thresh_min = t_min;
    thresh_max = t_max;
    variance_speed = v_spd;
  }

  void display_dot_scan(float xpos, float ypos) {
    frame = (frame+1) % imageCount;

    colorMode(HSB, 360, 100, 100);
    strokeWeight(1);
    int thresh = int(map(noise(float(millis()) * (0.001 * variance_speed)), 0, 1, thresh_min, thresh_max));

    for (int y = 0; y < images[frame].height; ++y) {
      int cumul = 0;

      for (int x = 0; x < images[frame].width; ++x) {
        color col = images[frame].pixels[y * images[frame].width + x];
        if(brightness(col) > 0) {
          cumul += brightness(col);
        }

        if (cumul >= thresh) {
          col = color(hue(col), map(saturation(col), 0, 100, 0, 100), 100);
          stroke(col);
          point(x + xpos, y + ypos);
          cumul = 0;
        }
      }
    }
    colorMode(RGB, 255, 255, 255);
  }
  
}