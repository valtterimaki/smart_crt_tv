//// basic static noise image distortion effect

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