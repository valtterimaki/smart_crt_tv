/*
Object that loads, manipulates and draws a prepared svg image.
Works only with svg's with paths and polygons
Inputs are, the xml file to be drawn, x, and y offset, amount of wobble.
*/


class ObjSvg {

  XML xml;
  float xoffs, yoffs;
  int rand;
  PVector[][][] parsed_svg = new PVector[2][50][50];

  ObjSvg (String xml_init, float xo, float yo, int rand_init) {

    xml = loadXML(xml_init);
    xoffs = xo;
    yoffs = yo;
    rand = rand_init;

    parsed_svg = svgParse();

  }


  /* Simple one-purpose SVG path & polygon parser  */

  PVector[][][] svgParse() {

    // Initiate exportable pvector array
    PVector[][][] result = new PVector[2][50][50];

    // Go through all paths
    XML[] paths = xml.getChildren("g/path");

    for (int i = 0; i < paths.length; ++i) {
      String path = paths[i].getString("d");
      String[] points = split(path, ' ');

      // find coordinates for each path
      for (int k = 0; k < points.length; ++k) {

        String point = points[k];
        point = point.replace("M", "");
        point = point.replace("L", "");

        String[] coords = split(point, ',');
        float xCoord = Float.parseFloat(coords[0]);
        float yCoord = Float.parseFloat(coords[1]);

        PVector converted = new PVector(xCoord, yCoord);

        result[0][i][k] = converted;
      }
    }

    // Go through all polys
    XML[] polys = xml.getChildren("g/polygon");

    for (int i = 0; i < polys.length; ++i) {
      String poly = polys[i].getString("points");
      String[] points = split(poly, ' ');

      int dividercounter = 0;

      for (int k = 0; k < points.length; k += 2) {

        float xCoord = Float.parseFloat(points[k]);
        float yCoord = Float.parseFloat(points[k+1]);

        PVector converted = new PVector(xCoord, yCoord);

        result[1][i][dividercounter] = converted;

        dividercounter += 1;
      }
    }

    // Return the whole 3-dimensional array
    return result;

  }

  /* Function that draws the svg paths */

  void display() {

    noFill();
    stroke(255);

    // draw path

    // go through paths
    for (int i = 0; i < 50; ++i) {
      // go through points
      if (parsed_svg[0][i][0] != null) {

        line(
        parsed_svg[0][i][0].x + xoffs + random(-rand, rand),
        parsed_svg[0][i][0].y + yoffs + random(-rand, rand),
        parsed_svg[0][i][1].x + xoffs + random(-rand, rand),
        parsed_svg[0][i][1].y + yoffs + random(-rand, rand)
        );
      }
    }

    // draw poly

    beginShape();
    // go through polys
    for (int i = 0; i < 50; ++i) {
      // go through points
      for (int k = 0; k < 50; ++k) {
        if (parsed_svg[1][i][k] != null) {
          vertex(
            parsed_svg[1][i][k].x + xoffs + random(-rand, rand),
            parsed_svg[1][i][k].y + yoffs + random(-rand, rand)
          );
        }
      }
    }

    endShape(CLOSE);
  }

}






