
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
  PImage outputImg;

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
    buffer = createGraphics(imageWidth, imageHeight, JAVA2D);
    outputImg = createImage(width, height, RGB);
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

    // Render source frame (possibly rotated) into CPU-side buffer — loadPixels() is free with JAVA2D
    buffer.beginDraw();
    buffer.background(0);
    buffer.translate(buffer.width / 2, buffer.height / 2);
    buffer.rotate(line_rotation);
    buffer.imageMode(CENTER);
    buffer.image(img, 0, 0);
    buffer.loadPixels();
    buffer.endDraw();

    // Threshold in 0-255 brightness units (original used 0-100 HSB brightness, so scale by 2.55)
    int thresh = (int)map(noise(millis() * 0.001 * variance_speed), 0, 1, thresh_min * 2.55, thresh_max * 2.55);

    float cosA = cos(-line_rotation);
    float sinA = sin(-line_rotation);
    float cx = xpos + buffer.width * 0.5;
    float cy = ypos + buffer.height * 0.5;
    int bw = buffer.width, bh = buffer.height;
    int sw = width, sh = height;

    // Write dots directly into pixel buffer — avoids N individual OpenGL point() calls
    outputImg.loadPixels();
    java.util.Arrays.fill(outputImg.pixels, 0xFF000000);

    for (int y = 0; y < bh; y++) {
      int cumul = 0;
      float ly = (y - bh * 0.5) * scale;
      int rowStart = y * bw;

      for (int x = 0; x < bw; x++) {
        int col = buffer.pixels[rowStart + x];
        int r = (col >> 16) & 0xFF;
        int g = (col >>  8) & 0xFF;
        int b =  col        & 0xFF;
        // Inline brightness = max(r,g,b), avoids RGB→HSB conversion
        int br = r > g ? (r > b ? r : b) : (g > b ? g : b);

        cumul += br;

        if (cumul >= thresh) {
          // Normalize to full brightness (equivalent to HSB brightness=100%)
          if (br > 0) {
            r = r * 255 / br;
            g = g * 255 / br;
            b = b * 255 / br;
          }
          // Apply inverse rotation to get screen coordinates
          float lx = (x - bw * 0.5) * scale;
          int px = (int)(cx + lx * cosA - ly * sinA);
          int py = (int)(cy + lx * sinA + ly * cosA);
          if (px >= 0 && px < sw && py >= 0 && py < sh) {
            outputImg.pixels[py * sw + px] = 0xFF000000 | (r << 16) | (g << 8) | b;
          }
          cumul = 0;
        }
      }
    }

    outputImg.updatePixels();
    image(outputImg, 0, 0);
  }

}