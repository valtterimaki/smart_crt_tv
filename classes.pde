
// Animator

class Animator {

  // variables
  // 'start' must be int, not float: millis() grows to ~10^9 after 11 days and
  // a float only has ~7 significant digits, so storing it as float loses
  // enough precision to corrupt animation timing.
  int start;
  float phase;
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
    // Compute elapsed as int arithmetic (small value, no precision loss) rather
    // than passing the huge absolute millis values directly into map().
    int elapsed = millis() - start - offset;
    phase = constrain(map(elapsed, 0, duration, 0, 1), 0, 1);
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

// Class for animating a sequence of images

class ImageSequence {
  String[] filenames;
  PImage currentImage;
  int imageWidth, imageHeight;
  int imageCount;
  int frame;
  int thresh_min, thresh_max, variance_speed;
  float line_rotation;
  float scale;
  PGraphics buffer;

  ImageSequence(String imagePrefix, int count, int digits, String format) {
    this(imagePrefix, 0, count, digits, format);
  }

  ImageSequence(String imagePrefix, int startFrame, int count, int digits, String format) {
    imageCount = count;
    filenames = new String[imageCount];
    for (int i = 0; i < imageCount; i++) {
      filenames[i] = imagePrefix + nf(i + startFrame, digits) + "." + format;
    }
    // Load only the first frame to get dimensions
    currentImage = loadImage(filenames[0]);
    imageWidth = currentImage.width;
    imageHeight = currentImage.height;
    buffer = createGraphics(imageWidth, imageHeight, P2D);
  }

  void loadFrame() {
    currentImage = loadImage(filenames[frame]);
  }

  void display(float xpos, float ypos) {
    frame = (frame+1) % imageCount;
    loadFrame();
    image(currentImage, xpos, ypos);
  }

  void dot_scan_settings(int t_min, int t_max, int v_spd) {
    thresh_min = t_min;
    thresh_max = t_max;
    variance_speed = v_spd;
    line_rotation = 0;
    scale = 1;
  }

  void dot_scan_settings(int t_min, int t_max, int v_spd, float l_rot, float scl) {
    thresh_min = t_min;
    thresh_max = t_max;
    variance_speed = v_spd;
    line_rotation = radians(l_rot);
    scale = scl;
  }

  void display_dot_scan(float xpos, float ypos) {
    frame = (frame+1) % imageCount;
    loadFrame();

    buffer.beginDraw();
    buffer.background(0);
    buffer.translate(buffer.width / 2, buffer.height / 2);
    buffer.rotate(line_rotation);
    buffer.imageMode(CENTER);
    buffer.image(currentImage, 0, 0);
    buffer.loadPixels();
    buffer.endDraw();

    colorMode(HSB, 360, 100, 100);
    strokeWeight(1);
    int thresh = int(map(noise(float(millis()) * (0.001 * variance_speed)), 0, 1, thresh_min, thresh_max));

    pushMatrix();
    translate(xpos + buffer.width / 2, ypos + buffer.height / 2);
    rotate(-line_rotation);

    for (int y = 0; y < buffer.height; ++y) {
      int cumul = 0;

      for (int x = 0; x < buffer.width; ++x) {
        color col = buffer.pixels[y * buffer.width + x];
        if(brightness(col) > 0) {
          cumul += brightness(col);
        }

        if (cumul >= thresh) {
          col = color(hue(col), map(saturation(col), 0, 100, 0, 100), 100);
          stroke(col);
          point(x * scale - buffer.width / (2 / scale), y * scale - buffer.height / (2 / scale));
          cumul = 0;
        }
      }
    }
    popMatrix();
    colorMode(RGB, 255, 255, 255);
  }

}