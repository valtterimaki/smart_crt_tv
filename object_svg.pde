/*
Object that loads, manipulates and draws a prepared svg image.
Works only with svg's with paths and polygons
Inputs are, the xml file to be drawn, x, and y offset, amount of wobble.
*/


class ObjSvg {

  XML xml;
  float xoffs, yoffs, fine, scale;
  int rand, spd;
  PVector[][][] parsed_svg = new PVector[3][50][50];
  float[] svg_noise = new float[50];

  ObjSvg (String xml_init, float xo, float yo, int rand_init, float fine_init, int spd_init, float sc) {

    xml = loadXML(xml_init);
    xoffs = xo;
    yoffs = yo;
    rand = rand_init;
    spd = spd_init;
    fine = fine_init;
    scale = sc;

    svgParse();

  }


  /* Simple one-purpose SVG path & polygon parser  */

  void svgParse() {

    // Go through all paths
    XML[] paths = xml.getChildren("g/path");

    for (int i = 0; i < paths.length; ++i) {
      String path = paths[i].getString("d");
      path = path.replace(" Z", "");
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

        parsed_svg[0][i][k] = converted;
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

        parsed_svg[1][i][dividercounter] = converted;

        dividercounter += 1;
      }
    }

      // Go through all polylines
    XML[] polylines = xml.getChildren("g/polyline");

    for (int i = 0; i < polylines.length; ++i) {
      String polyline = polylines[i].getString("points");
      String[] points = split(polyline, ' ');

      int dividercounter = 0;

      for (int k = 0; k < points.length; k += 2) {

        float xCoord = Float.parseFloat(points[k]);
        float yCoord = Float.parseFloat(points[k+1]);

        PVector converted = new PVector(xCoord, yCoord);

        parsed_svg[2][i][dividercounter] = converted;

        dividercounter += 1;
      }
    }
  }




  /* Noise update */

  void update() {

  }


  /* Function that draws the svg paths */

  void display() {

    noFill();
    stroke(255);
    strokeWeight(2);

    noiseDetail(4,0.7);

    // draw paths

    // go through paths
    for (int i = 0; i < 50; ++i) {
      // go through points
      if (parsed_svg[0][i][0] != null) {

        noiseSeed(i);

        line(
        parsed_svg[0][i][0].x * scale + xoffs + Ease.quinticBoth(Ease.quinticBoth(noise(float(millis()) / spd + i*0.3 + random(0.1), 110))) * rand + random(fine),
        parsed_svg[0][i][0].y * scale + yoffs + Ease.quinticBoth(Ease.quinticBoth(noise(float(millis()) / spd + i*0.3 + random(0.1), 220))) * rand + random(fine),
        parsed_svg[0][i][1].x * scale + xoffs + Ease.quinticBoth(Ease.quinticBoth(noise(float(millis()) / spd + i*0.3 + random(0.1), 330))) * rand + random(fine),
        parsed_svg[0][i][1].y * scale + yoffs + Ease.quinticBoth(Ease.quinticBoth(noise(float(millis()) / spd + i*0.3 + random(0.1), 440))) * rand + random(fine)
        );
      }
    }

    // draw polys

    // go through polys
    for (int i = 0; i < 50; ++i) {
      beginShape();

      // go through points
      for (int k = 0; k < 50; ++k) {
        if (parsed_svg[1][i][k] != null) {

          noiseSeed(k+i);

          vertex(
            parsed_svg[1][i][k].x * scale + xoffs + Ease.quinticBoth(Ease.quinticBoth(noise(float(millis()) / spd + k*0.3 + random(0.1), 550))) * rand + random(fine),
            parsed_svg[1][i][k].y * scale + yoffs + Ease.quinticBoth(Ease.quinticBoth(noise(float(millis()) / spd + k*0.3 + random(0.1), 660))) * rand + random(fine)
          );

        }
      }
      endShape(CLOSE);
    }

    // draw polylines

    // go through polylines
    for (int i = 0; i < 50; ++i) {
      beginShape();

      // go through points
      for (int k = 0; k < 50; ++k) {
        if (parsed_svg[2][i][k] != null) {

          noiseSeed(k+i);

          vertex(
            parsed_svg[2][i][k].x * scale + xoffs + Ease.quinticBoth(Ease.quinticBoth(noise(float(millis()) / spd + k*0.3 + random(0.1), 550))) * rand + random(fine),
            parsed_svg[2][i][k].y * scale + yoffs + Ease.quinticBoth(Ease.quinticBoth(noise(float(millis()) / spd + k*0.3 + random(0.1), 660))) * rand + random(fine)
          );

        }
      }
      endShape();
    }

  }

}
