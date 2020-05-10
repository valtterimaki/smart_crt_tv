
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
  '\uE250'  // curve
};


// Pesudocode object

class PseudoCodeOne {

  String pseudocode_string;

  PseudoCodeOne () {
    pseudocode_string = new String(pseudo_symbols);
  }

  void setup() {
    textFont(tesserae);
    fill(255);
    textSize(20);
  }

  void update() {

  }

  void draw() {
    text(pseudocode_string, 16, 16);
  }

}

