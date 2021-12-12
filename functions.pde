
//// Signum function to see if number is positive or negative

int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
}


//// Colored text

void coloredText(String str, float xpos, float ypos, float xdim , float ydim, int[][] colr, int lead) {
  String curr;
  String curr_word = "";
  String curr_line = "";
  float xcurr = xpos;
  float ycurr = ypos;
  int[][] colors = colr;
  int char_counter = 0;

  for (int i = 0; i < str.length(); ++i) {

    if ( str.substring(i, i+1).equals("\u2424") || str.substring(i, i+1).equals("\u2424" ) || i == str.length() - 1  ) {

      if (textWidth(curr_line) + textWidth("\u2424") + textWidth(curr_word) < xdim) {
        curr_line += curr_word + "\u2424";
        curr_word = "";
      }
      if (textWidth(curr_line) + textWidth("\u2424") + textWidth(curr_word) >= xdim && textWidth(curr_word) < xdim) {
        char_counter = coloredTextLine(curr_line, xcurr, ycurr, colors, char_counter);
        ycurr += lead;
        curr_line = curr_word + "\u2424";
        curr_word = "";
      }
      if (textWidth(curr_line) + textWidth("\u2424") + textWidth(curr_word) >= xdim && textWidth(curr_word) >= xdim) {
        char_counter = coloredTextLine(curr_line, xcurr, ycurr, colors, char_counter);
        ycurr += lead;

        for (int j = 0; j < curr_word.length(); ++j) {
          if (textWidth(curr_word.substring(0, j)) >= xdim) {
            char_counter = coloredTextLine(curr_word.substring(0, j), xcurr, ycurr, colors, char_counter);
            ycurr += lead;
            curr_line = curr_word.substring(j, curr_word.length()) + "\u2424";
            curr_word = "";
          }
        }
      }
    }

    else if (str.substring(i, i+1).equals("\n")) {
        curr_line += curr_word;
        char_counter = coloredTextLine(curr_line, xcurr, ycurr, colors, char_counter);
        ycurr += lead;
        curr_line = "";
        curr_word = "";
    }

    else {
      curr_word = curr_word + str.substring(i, i+1);
    }

    // check if string end reached
    if (i == str.length() - 1 ) {
      curr_line += curr_word + "\u2424";
      char_counter = coloredTextLine(curr_line, xcurr, ycurr, colors, char_counter);
    }
  }
}

int coloredTextLine(String str, float xpos, float ypos, int[][] colr, int cha) {

  float xcurr = xpos;
  int[][] colors;
  colors = colr;
  int character = cha;

  for (int i = 0; i < str.length(); ++i) {

    for (int j = 0; j < colors.length ; ++j) {
      if (colors[j][0] == character) {
       fill(colors[j][1], colors[j][2], colors[j][3]);
      }
    }

    text(str.substring(i, i+1), xcurr, ypos);
    xcurr += textWidth(str.substring(i, i+1));

    character++;
  }

  return character;

}


//// Cubic interpolation

float cerp(float min, float max, float in, float out, float t){
  return bezierPoint(min, in, max-out, max, t);
}


//// Program changer that randomizes one round of programs so they appear evenly

void programChange() {

  if (program_cycle_counter == 0 || program_cycle_counter == program_cycle.length) {

    // Update weather every time we randomize the loop
    weather.update();

    int[] randomarray =  new int[program_cycle.length];
    for(int t=0; t<randomarray.length; t++){
      randomarray[t]=t+1;
    }
      for (int k=0; k < randomarray.length; k++) {
        // Goal: swap the value at pos k with a rnd value at pos x.
        // save current value from pos/index k into temp
        int temp = randomarray[k];
        // make rnd index x
        int x = (int)random(0, randomarray.length);
        // overwrite value at current pos k with value at rnd index x
        randomarray[k]=randomarray[x];
        // finish swapping by giving the old value at pos k to the
        // pos x.
        randomarray[x]=temp;
      }

    program_cycle = randomarray;
    program_cycle_counter = 1;
    program_number = program_cycle[program_cycle_counter-1];

  }

  else {
    program_cycle_counter++;
    program_number = program_cycle[program_cycle_counter-1];
  }

}

//// test for changing programs for debugging

void programChangeTest(int test1, int test2) {   // Put tested numbers here
  program_cycle[0] = test1;
  program_cycle[1] = test2;
  program_cycle_counter++;
  program_number = program_cycle[program_cycle_counter-1];
}


//// manually speed up program change

void keyPressed() {
  counter+=4;
}


//// drawing the shape for a cloud

void cloudShape(float x_pos, float y_pos, float x_dim, float y_dim) {
  beginShape();
  vertex(x_pos, y_pos);
  vertex(x_pos + x_dim, y_pos);
  bezierVertex(x_pos + x_dim + y_dim, y_pos, x_pos + x_dim + y_dim, y_pos + y_dim, x_pos + x_dim, y_pos + y_dim);
  vertex(x_pos, y_pos + y_dim);
  bezierVertex(x_pos - y_dim, y_pos + y_dim, x_pos - y_dim, y_pos, x_pos, y_pos);
  endShape();
}


//// drawing the shape for a cloud shadow

void cloudShadow(float x_pos, float y_pos, float x_dim, float y_dim) {
  int spacing = 9;
  for (int i = 1; i < x_dim ; i += spacing) {
    line(
      x_pos + i + 2*y_dim,
      y_pos,
      x_pos + i,
      y_pos + y_dim
      );
  }

}

//// basic static noise image distortion effect

void fxStatic() {

  int distortion_min = 2;
  int distortion_max = int(Ease.quinticIn(noise(millis()/1000))*100) + 6;

  loadPixels();
  for (int i = 0; i < height; ++i) {
    if (int(random(100)) == 1) {
      for (int j = 0; j < width; ++j) {
        if (i < height - 1) {
          pixels[(i*width+j)] = pixels[(i*width+j+int(random(distortion_min, distortion_max)))];
        }
      }
    }
  }
  updatePixels();
}

//custom brightness function (not used atm)
void fxBrightnessAmp(float factor) {

  float f = constrain(factor, 0, 1);

  loadPixels();
  for (int i = 0; i < height; ++i) {
    for (int j = 0; j < width; ++j) {
      float r = red(pixels[(i*width+j)]);
      float g = green(pixels[(i*width+j)]);
      float b = blue(pixels[(i*width+j)]);

      pixels[(i*width+j)] = color(r * (f * (255-r)), g * (f * (255-g)), b * (f * (255-b)));
    }
  }
  updatePixels();
}


// exit with mousepress

void mousePressed() {
  exit();
}


// get highest or lowest value in arraylist

int getHighestOrLowest(ArrayList<String> src, String which, int from, int to) {

  ArrayList<String> source = src;
  float val1 = float(source.get(from));
  float val2;
  int index = from;

  for (int i = from + 1; i < to; ++i) {
    val2 = float(source.get(i));
    if (val2 > val1 && which == "highest") {
      val1 = val2;
      index = i;
    }
    if (val2 < val1 && which == "lowest") {
      val1 = val2;
      index = i;
    }
  }

  return index;

}


// Dashed line ( by Luhai Cui https://openprocessing.org/sketch/474079 )

void dashedLine(float x1, float y1, float x2, float y2, float l, float g) {
  float pc = dist(x1, y1, x2, y2) / 100;
  float pcCount = 0.5;
  float gPercent = 0;
  float lPercent = 0;
  float currentPos = 0;
  float xx1 = 0,
    yy1 = 0,
    xx2 = 0,
    yy2 = 0;

  while (pcCount * pc < l) {
    pcCount++;
  }
  lPercent = pcCount;
  pcCount = 1;
  while (pcCount * pc < g) {
    pcCount++;
  }
  gPercent = pcCount;

  lPercent = lPercent / 100;
  gPercent = gPercent / 100;
  while (currentPos < 1) {
    xx1 = lerp(x1, x2, currentPos);
    yy1 = lerp(y1, y2, currentPos);
    xx2 = lerp(x1, x2, currentPos + lPercent);
    yy2 = lerp(y1, y2, currentPos + lPercent);
    if (x1 > x2) {
      if (xx2 < x2) {
        xx2 = x2;
      }
    }
    if (x1 < x2) {
      if (xx2 > x2) {
        xx2 = x2;
      }
    }
    if (y1 > y2) {
      if (yy2 < y2) {
        yy2 = y2;
      }
    }
    if (y1 < y2) {
      if (yy2 > y2) {
        yy2 = y2;
      }
    }

    line(xx1, yy1, xx2, yy2);
    currentPos = currentPos + lPercent + gPercent;
  }
}



// Shaded text

void textShaded(String txt, float x, float y, int color1, int color2, int offs) {

  int[] offsets_x = {-offs,offs,-offs,offs,0};
  int[] offsets_y = {-offs,-offs,offs,offs,0};

  fill(color2);

  for (int i = 0; i < 5; ++i) {
    if (i == 4) {
      fill(color1);
    }
    text(txt, x + offsets_x[i], y + offsets_y[i]);
  }
}


// Striped box fill (angle in radians)

void rectStriped(float x_pos, float y_pos, float x_dim_input, float y_dim_input, float spacing, float angle_input) {

  float x_dim = abs(x_dim_input);
  float y_dim = abs(y_dim_input);
  float angle_norm = angle_input % TAU;
  float angle = HALF_PI;
  float flip = 0;

  /* //test, remove
  noStroke();
  fill(100);
  rect(x_pos, y_pos, x_dim_input, y_dim_input);
  stroke(255,0,0);
  // end test */

  // convert angle and define flip to ease drawing
  if (angle_norm >= 0 && angle_norm < HALF_PI) {
    angle = angle_norm;
    flip = 0;
  }
  if (angle_norm > HALF_PI && angle_norm < PI) {
    angle = PI-angle_norm;
    flip = x_dim;
  }
  if (angle_norm >= PI && angle_norm < HALF_PI*3) {
    angle = angle_norm-PI;
    flip = 0;
  }
  if (angle_norm > HALF_PI*3 && angle_norm < TAU) {
    angle = TAU-angle_norm;
    flip = x_dim;
  }

  pushMatrix();

  translate(x_pos, y_pos);
  scale(signum(x_dim_input), signum(y_dim_input));

  if (angle != HALF_PI) {

    float spacing_y = (spacing / cos(angle));
    float offset_y = (x_dim * tan(angle));
    float spacing_x = (spacing / sin(angle));

    for (float i = spacing_y; i < y_dim ; i +=spacing_y ) {
      if (i < y_dim - offset_y) {
        line(
          map(0, 0, x_dim, flip, x_dim - flip),
          i,
          map(x_dim, 0, x_dim, flip, x_dim - flip),
          offset_y + i
        );
      }
      else {
        //stroke(255); // debug color
        line(
          map(0, 0, x_dim, flip, x_dim - flip),
          i,
          map((y_dim - i) / tan(angle), 0, x_dim, flip, x_dim - flip),
          y_dim
        );
      }
    }
    for (float i = 0; i < x_dim; i +=spacing_x) {
      //stroke(0,255,0); // debug color
      if ((tan(angle) * (x_dim - i)) < y_dim) {
        line(
          map(i, 0, x_dim, flip, x_dim - flip),
          0,
          map(x_dim, 0, x_dim, flip, x_dim - flip),
          (tan(angle) * (x_dim - i))
        );
      } else {
        line(
          map(i, 0, x_dim, flip, x_dim - flip),
          0,
          map(y_dim / tan(angle) + i, 0, x_dim, flip, x_dim - flip),
          y_dim
        );
      }
    }
  } else {
    for (float i = 0; i < x_dim; i +=spacing) {
      line(
        i,
        0,
        i,
        y_dim
      );
    }
  }

  popMatrix();

}

// Specific datetime difference calculator

int localDateTimeDiff(LocalDateTime from, LocalDateTime to, String type) {

  LocalDateTime fromTemp = LocalDateTime.from(from);

  long days = fromTemp.until(to, ChronoUnit.DAYS);
  fromTemp = fromTemp.plusDays(days);

  long hours = fromTemp.until(to, ChronoUnit.HOURS);
  fromTemp = fromTemp.plusHours(hours);

  long minutes = fromTemp.until(to, ChronoUnit.MINUTES);

  if (type.equals("d")) {
    return int(days);
  }
  if (type.equals("h")) {
    return int(hours);
  }
  if (type.equals("m")) {
    return int(minutes);
  }

  // 0 if something fails
  return 0;
}


float mapEased(float val, float lo1, float hi1, float lo2, float hi2) {

  // convert the input value to 0.0 - 1.0 range
  float phase = (val - lo1) / (hi1 - lo1);

  // map the value to the desired range with the eased phase
  float result = map(Ease.cubicBoth(phase), 0, 1, lo2, hi2);

  return result;

}



