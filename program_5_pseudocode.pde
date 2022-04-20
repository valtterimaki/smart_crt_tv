
// Pseudo code character map array

char pseudo_symbols[] = {
  '\uE06C', // squares
  '\uE06D',
  '\uE06F',
  '\uE50A',
  '\uE095', // balls
  '\uE097',
  '\uE22A',
  '\uE33B',
  '\uE221', // arcs
  '\uF574',
  '\uF575',
  '\uF59E',
  '\uE505', // dots
  '\uE62F',
  '\uE630',
  '\uE638', // small dots
  '\uE509',
  '\uE502',
  '\uE26D', // dense dots
  '\uE504',
  '\uE631',
  '\uE01D', // sideways U
  '\uF5BC', // small sideways U
  '\uE250', // curve
  '\u2424', // big space
  '\n'  // line break
};

int pseudo_symbols_weight[] = {
  1,3,4,7, 1,5,6,7, 2,2,2,2, 2,2,2, 2,2,2, 2,2,2, 1,1,2, 20,8
};


// Pesudocode object

class PseudoCodeOne {

  String time_now;
  int frame_counter;
  String pseudocode_string;
  String animated_string;
  String test_string = "testisana-1 testisana-2 testisana-3\nrivinvaihto testisana-pidempi-4 testisana-5 testisana-6 testisana-7 testisana-pidempi-8 testisana-9 FUCKING-long-text-that-is-very-very-long-like-this-here-saatana testisana-10 loppu"; // test, delete later
  int char_amount;
  int[] cumulative_weights = new int[pseudo_symbols_weight.length];
  int weight_rand;
  int weight_selection;
  int streak;
  int color_block_x;
  int color_block_y;
  int color_block_len;
  int text_size = 20;

  int[][] testcolors = { {0,255,255,255}, {0,255,0,0}, {0,255,255,255} };
  int color_pos;

  PseudoCodeOne () {
    cumulative_weights[0] = pseudo_symbols_weight[0];
    for (int i = 1; i < cumulative_weights.length; ++i) {
      cumulative_weights[i] = pseudo_symbols_weight[i] + cumulative_weights[i-1];
    }
  }

  void setup() {

    frame_counter = 0;
    streak = -1;
    time_now = "";

    textSize(text_size);
    textLeading(text_size);

    char_amount = int(random(200,300));
    char[] pseudocode_array = new char[char_amount];

    color_pos = int(random(1,300));
    testcolors[1][0] = color_pos;
    testcolors[2][0] = color_pos + int(random(1,20));

    for (int i = 0; i < char_amount; ++i) {

      if (streak >= 0 && random(10) > 1) {
        pseudocode_array[i] = pseudo_symbols[streak];
        if (random(4) < 1) {
          streak = -1;
        }
      }

      else {
        weight_rand = int(random(cumulative_weights[cumulative_weights.length-1]));
        for (int k = 0; k < cumulative_weights.length; ++k) {
          if (cumulative_weights[k] >= weight_rand) {
            weight_selection = k;
            break;
          }
        }
        pseudocode_array[i] = pseudo_symbols[weight_selection];
      }

      if (random(10) < 1) {
        streak = weight_selection;
      }
    }

    pseudocode_string = new String(pseudocode_array);

  }

  void update() {
    frame_counter += 2;

    if (frame_counter <= pseudocode_string.length()) {
      animated_string = pseudocode_string.substring(0, frame_counter)
                      + pseudo_symbols[int(random(pseudo_symbols.length-1))]
                      + pseudo_symbols[int(random(pseudo_symbols.length-1))]
                      + pseudo_symbols[int(random(pseudo_symbols.length-1))]
                      + '\uE06C';
    }
    else if (frame_counter == pseudocode_string.length()) {
      animated_string = pseudocode_string.substring(0, frame_counter);
    }
    else {
      time_now = str(hour()) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
    }
  }

  void draw() {

    noStroke();
    fill(255);
    textFont(tesserae);
    coloredText(animated_string, os_left + 32, os_top + 40, width - 64, height - 128, testcolors, text_size);

    textFont(source_code_light);
    fill(0);
    rect(width - os_right - 150, height - os_bottom - 48 -text_size, textWidth(time_now), text_size * 1.3);
    fill(255);
    text(time_now, width - os_right - 150, height - os_bottom - 48);

  }

}

