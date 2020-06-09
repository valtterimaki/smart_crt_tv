// Signum function to get plus or minus

int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
}


// Colored text

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
       println("shit "+j);
       fill(colors[j][1], colors[j][2], colors[j][3]);
      }
    }

    text(str.substring(i, i+1), xcurr, ypos);
    xcurr += textWidth(str.substring(i, i+1));

    character++;
  }

  return character;

}


// Cubic interpolation

float cerp(float min, float max, float in, float out, float t){
  return bezierPoint(min, in, max-out, max, t);
}


