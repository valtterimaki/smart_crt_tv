
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
  PImage outputImg;

  // display_dot_scan() row bands, one worker per core. Built on first scan.
  BandWorker[] bandWorkers;
  Future[] bandFutures;

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
    outputImg = createImage(width, height, ARGB);
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

  // Rows are independent (cumul resets every row), so the scan is split into
  // contiguous row bands across the cores. Two rows can land on the same output
  // pixel under rotation/scale; that write is left unsynchronized - an int store
  // is atomic so the worst case is last-writer-wins on a single dot's color.
  void ensureBandWorkers(int iw, int ih) {
    int bands = max(1, dotScanBands);
    int cap = ceil(ih / (float)bands) * iw; // at most one dot per inner iteration
    if (bandWorkers != null && bandWorkers.length == bands
      && bandWorkers[0].dirty.length >= cap) return;

    bandWorkers = new BandWorker[bands];
    for (int i = 0; i < bands; i++) bandWorkers[i] = new BandWorker(cap);
    bandFutures = new Future[bands];
    // Any old dirty lists are gone, so the incremental clear cannot undo the
    // previous frame's dots - wipe the whole buffer this once.
    java.util.Arrays.fill(outputImg.pixels, 0x00000000);
  }

  void display_dot_scan(float xpos, float ypos) {
    advance();
    PImage img = currentImg();
    if (img == null) return;

    img.loadPixels();
    int iw = img.width, ih = img.height;

    // Threshold scaled to 0-255 brightness (original was 0-100 HSB)
    int thresh = (int)map(noise(millis() * 0.001 * variance_speed), 0, 1, thresh_min * 2.55, thresh_max * 2.55);

    // Precompute rotation coefficients (constant for entire frame)
    float cosLR = cos(line_rotation);
    float sinLR = sin(line_rotation);
    float halfW = iw * 0.5f, halfH = ih * 0.5f;
    float cx = xpos + halfW;
    float cy = ypos + halfH;
    int sw = width, sh = height;

    outputImg.loadPixels();
    ensureBandWorkers(iw, ih);
    int bands = bandWorkers.length;

    // Clear only the dots written last frame (a few thousand stores instead of a
    // 414k-int memset). Done here on the draw thread and before any worker is
    // dispatched, so no worker can zero a dot another worker just wrote.
    for (int i = 0; i < bands; i++) bandWorkers[i].clearDirty(outputImg.pixels);

    for (int i = 0; i < bands; i++) {
      bandWorkers[i].setup(
        img.pixels, outputImg.pixels,
        i * ih / bands, (i + 1) * ih / bands,
        iw, ih, sw, sh,
        thresh, cosLR, sinLR, halfW, halfH, cx, cy, scale
      );
    }

    // Workers 1..n-1 go to the pool, band 0 runs here so all cores are busy.
    for (int i = 1; i < bands; i++) bandFutures[i] = dotScanPool.submit(bandWorkers[i]);
    bandWorkers[0].run();
    for (int i = 1; i < bands; i++) {
      // get() is also the memory barrier that publishes the workers' writes here
      try {
        bandFutures[i].get();
      }
      catch (Exception e) {
        // A dropped band must cost a slow frame, not the whole display
        println("dot scan band " + i + " failed: " + e);
        bandWorkers[i].run();
      }
    }

    outputImg.updatePixels();
    image(outputImg, 0, 0);
  }

}

// One row band of ImageSequence.display_dot_scan(). Pure array math - must not
// touch any Processing API, since it runs off the draw thread.
class BandWorker implements Runnable {
  int[] src, out;
  int[] dirty;      // out[] indices written last run, for the next clear
  int dirtyCount;
  int y0, y1, iw, ih, sw, sh, thresh;
  float cosLR, sinLR, halfW, halfH, cx, cy, scl;

  BandWorker(int capacity) {
    dirty = new int[capacity];
    dirtyCount = 0;
  }

  void clearDirty(int[] pixels) {
    for (int i = 0; i < dirtyCount; i++) pixels[dirty[i]] = 0x00000000;
    dirtyCount = 0;
  }

  void setup(int[] src_, int[] out_, int y0_, int y1_,
    int iw_, int ih_, int sw_, int sh_,
    int thresh_, float cosLR_, float sinLR_,
    float halfW_, float halfH_, float cx_, float cy_, float scl_) {
    src = src_;
    out = out_;
    y0 = y0_;
    y1 = y1_;
    iw = iw_;
    ih = ih_;
    sw = sw_;
    sh = sh_;
    thresh = thresh_;
    cosLR = cosLR_;
    sinLR = sinLR_;
    halfW = halfW_;
    halfH = halfH_;
    cx = cx_;
    cy = cy_;
    scl = scl_;
  }

  public void run() {
    for (int y = y0; y < y1; y++) {
      int cumul = 0;
      float by_c = y - halfH;
      // Row-constant rotation terms (avoids 2 multiplications per inner pixel)
      float by_sinLR = by_c * sinLR;
      float by_cosLR = by_c * cosLR;

      for (int x = 0; x < iw; x++) {
        float bx_c = x - halfW;
        // Rotate (bx_c, by_c) by line_rotation to get source image sample point
        float rot_x = bx_c * cosLR + by_sinLR;
        float rot_y = by_cosLR - bx_c * sinLR;
        int srcX = (int)(rot_x + halfW);
        int srcY = (int)(rot_y + halfH);

        int col = (srcX >= 0 && srcX < iw && srcY >= 0 && srcY < ih)
          ? src[srcY * iw + srcX] : 0;

        int r = (col >> 16) & 0xFF;
        int g = (col >>  8) & 0xFF;
        int b =  col        & 0xFF;
        int br = r > g ? (r > b ? r : b) : (g > b ? g : b);

        cumul += br;

        if (cumul >= thresh) {
          if (br > 0) {
            r = r * 255 / br;
            g = g * 255 / br;
            b = b * 255 / br;
          }
          // Screen position: same rotation applied at scale (rot_x,rot_y already computed)
          int px = (int)(cx + rot_x * scl);
          int py = (int)(cy + rot_y * scl);
          if (px >= 0 && px < sw && py >= 0 && py < sh) {
            int idx = py * sw + px;
            out[idx] = 0xFF000000 | (r << 16) | (g << 8) | b;
            if (dirtyCount < dirty.length) dirty[dirtyCount++] = idx;
          }
          cumul = 0;
        }
      }
    }
  }
}