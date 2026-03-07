
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
  PImage[] ringBuf;
  final int BUF_SIZE = 60;   // more headroom for parallel loaders
  final int NUM_LOADERS = 3; // use 3 of Pi4's 4 cores for decoding
  int imageWidth, imageHeight;
  int imageCount;
  int frame; // current file index, kept for compatibility
  int thresh_min, thresh_max, variance_speed;
  float line_rotation;
  float scale;
  PGraphics buffer;

  volatile long displaySeqPos;
  long nextLoadPos;          // guarded by synchronized(this)
  Thread[] loaderThreads;
  volatile boolean preloaderRunning;

  ImageSequence(String imagePrefix, int count, int digits, String format) {
    this(imagePrefix, 0, count, digits, format);
  }

  ImageSequence(String imagePrefix, int startFrame, int count, int digits, String format) {
    imageCount = count;
    filenames = new String[imageCount];
    for (int i = 0; i < imageCount; i++) {
      filenames[i] = imagePrefix + nf(i + startFrame, digits) + "." + format;
    }
    ringBuf = new PImage[BUF_SIZE];
    // Load only frame 0 synchronously to get dimensions; threads fill the rest
    ringBuf[0] = loadImage(filenames[0]);
    imageWidth = ringBuf[0].width;
    imageHeight = ringBuf[0].height;
    buffer = createGraphics(imageWidth, imageHeight, P2D);
    displaySeqPos = 0;
    nextLoadPos = 1;
    frame = 0;
    loaderThreads = new Thread[NUM_LOADERS];
    startPreloader();
  }

  void startPreloader() {
    preloaderRunning = true;
    final ImageSequence self = this;
    for (int i = 0; i < NUM_LOADERS; i++) {
      loaderThreads[i] = new Thread(new Runnable() {
        public void run() {
          while (self.preloaderRunning) {
            long myPos;
            synchronized(self) {
              if (self.nextLoadPos - self.displaySeqPos >= self.BUF_SIZE) {
                myPos = -1; // buffer full
              } else {
                myPos = self.nextLoadPos++;
              }
            }
            if (myPos < 0) {
              try { Thread.sleep(5); } catch (InterruptedException e) { break; }
              continue;
            }
            int slot = (int)(myPos % self.BUF_SIZE);
            int fi   = (int)(myPos % self.imageCount);
            PImage img = loadImage(self.filenames[fi]);
            if (img != null) self.ringBuf[slot] = img;
          }
        }
      });
      loaderThreads[i].setDaemon(true);
      loaderThreads[i].start();
    }
  }

  void stopLoaders() {
    preloaderRunning = false;
    for (int i = 0; i < NUM_LOADERS; i++) {
      if (loaderThreads[i] != null) {
        loaderThreads[i].interrupt();
        try { loaderThreads[i].join(200); } catch (InterruptedException e) {}
      }
    }
  }

  // Seek to a new start position (next display() call will show fileIdx+1)
  void seek(int fileIdx) {
    stopLoaders();
    displaySeqPos = fileIdx;
    frame = fileIdx;
    // Load only the one frame that will be shown immediately after advance()
    int firstSlot = (int)((fileIdx + 1) % BUF_SIZE);
    int firstFile = (int)((fileIdx + 1) % imageCount);
    ringBuf[firstSlot] = loadImage(filenames[firstFile]);
    nextLoadPos = fileIdx + 2;
    startPreloader();
  }

  PImage currentImg() {
    return ringBuf[(int)(displaySeqPos % BUF_SIZE)];
  }

  void advance() {
    displaySeqPos++;
    frame = (int)(displaySeqPos % imageCount);
  }

  void display(float xpos, float ypos) {
    advance();
    PImage img = currentImg();
    if (img != null) image(img, xpos, ypos);
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
    advance();
    PImage img = currentImg();
    if (img == null) return;

    buffer.beginDraw();
    buffer.background(0);
    buffer.translate(buffer.width / 2, buffer.height / 2);
    buffer.rotate(line_rotation);
    buffer.imageMode(CENTER);
    buffer.image(img, 0, 0);
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