
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
  PImage[] images;
  int imageCount;
  int frame;
  int thresh_min, thresh_max, variance_speed;
  
  ImageSequence(String imagePrefix, int count, int digits, String format) {
    imageCount = count;
    images = new PImage[imageCount];

    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into four digits
      String filename = imagePrefix + nf(i, digits) + "." + format;
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

// Class for movie with dot scan

class MovieScan {

  // defaults for scan
  int thresh_min, thresh_max, variance_speed;
  float line_rotation;

  MovieScan() {
    // defaults for scan
    thresh_min = 5;
    thresh_max = 1000; 
    variance_speed = 1;
    line_rotation = 0;
  }

  void display(float xpos, float ypos) {
    image(genMovie, xpos, ypos);
  }

  void dot_scan_settings(int t_min, int t_max, int v_spd, float l_rot) {
    thresh_min = t_min;
    thresh_max = t_max;
    variance_speed = v_spd;
    line_rotation = radians(l_rot);
  }

  void display_dot_scan(float xpos, float ypos) {

    if (genMovie == null) return;

    vid_gen_buffer.beginDraw();
    vid_gen_buffer.translate(vid_gen_buffer.width / 2, vid_gen_buffer.height / 2); // Move to the center
    vid_gen_buffer.rotate(line_rotation); // Rotate based on frame count
    vid_gen_buffer.imageMode(CENTER); // Draw image from center
    vid_gen_buffer.image(genMovie, 0,0);
    vid_gen_buffer.loadPixels();
    vid_gen_buffer.endDraw();

    colorMode(HSB, 360, 100, 100);
    strokeWeight(1);
    int thresh = int(map(noise(float(millis()) * (0.001 * variance_speed)), 0, 1, thresh_min, thresh_max));

    pushMatrix();
    translate(width / 2, height / 2);
    rotate(-line_rotation); 
    //image(vid_gen_buffer, 0, 0);

    for (int y = 0; y < vid_gen_buffer.height; ++y) {
      int cumul = 0;

      for (int x = 0; x < vid_gen_buffer.width; ++x) {

        color col = vid_gen_buffer.pixels[y * vid_gen_buffer.width + x];
        
        /*if (random(0,1000) < 1) {
          col = col + color(random(200,255), random(200,255), random(200,255));
        }*/

        if(brightness(col) > 0) {
          cumul += brightness(col);
        }

        if (cumul >= thresh) {
          col = color(hue(col), map(saturation(col), 0, 100, 0, 100), 100);
          stroke(col);
          point(x + xpos - (vid_gen_buffer.width/2), y + ypos - (vid_gen_buffer.height/2));
          cumul = 0;
        }
      }
    }
    popMatrix();
    colorMode(RGB, 255, 255, 255);
  }
  
}