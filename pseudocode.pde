
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
  ' '       // space
};

int pseudo_symbols_weight[] = {
  1,1,1,1,50,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,10
};


// Pesudocode object

class PseudoCodeOne {

  String pseudocode_string;
  int char_amount;
  int[] cumulative_weights = new int[pseudo_symbols_weight.length];
  int weight_rand;
  int weight_selection;

  PseudoCodeOne () {
    cumulative_weights[0] = pseudo_symbols_weight[0];
    for (int i = 1; i < cumulative_weights.length; ++i) {
      cumulative_weights[i] = pseudo_symbols_weight[i] + cumulative_weights[i-1];
    }
  }

  void setup() {
    textFont(tesserae);
    fill(255);
    textSize(20);

    char_amount = int(random(100, 200));
    char[] pseudocode_array = new char[char_amount];

    for (int i = 0; i < char_amount; ++i) {
      weight_rand = int(random(cumulative_weights[cumulative_weights.length-1]));
      for (int k = 0; k < cumulative_weights.length; ++k) {
        if (cumulative_weights[k] >= weight_rand) {
          weight_selection = k;
          break;
        }
      }

      pseudocode_array[i] = pseudo_symbols[weight_selection];
    }

    pseudocode_string = new String(pseudocode_array);
  }

  void update() {

  }

  void draw() {
    text(pseudocode_string, 16, 32, width - 64, height - 64);
  }

}

