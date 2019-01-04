/* Simple one-purpose SVG path & polygon parser  */

PVector[][][] svgParse(String xml_init) {
  XML xml;
  xml = loadXML(xml_init);

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

void svgDraw(String xml_init) {

  noFill();
  stroke(255);

  // draw path

  // go through paths
  for (int i = 0; i < 50; ++i) {
    // go through points
    if (svgParse(xml_test)[0][i][0] != null) {

      line(
      svgParse(xml_test)[0][i][0].x,
      svgParse(xml_test)[0][i][0].y,
      svgParse(xml_test)[0][i][1].x,
      svgParse(xml_test)[0][i][1].y
      );
    }
  }

  // draw poly

  beginShape();
  // go through polys
  for (int i = 0; i < 50; ++i) {
    // go through points
    for (int k = 0; k < 50; ++k) {
      if (svgParse(xml_test)[1][i][k] != null) {
        vertex(svgParse(xml_test)[1][i][k].x , svgParse(xml_test)[1][i][k].y);
      }
    }
  }
  endShape(CLOSE);


}






















