/* Simple one-purpose SVG path & polygon parser  */

PVector svgParse(String xml_init, String set, int shape, int coordinate) {
  XML xml;
  xml = loadXML(xml_init);

  // Initiate final arrays to be exported
  PVector[][] final_paths = new PVector[100][2];
  PVector[][] final_polys = new PVector[100][100];

  // Initiate exportable pvector
  PVector result = new PVector();

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

      final_paths[i][k] = converted;
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

      final_polys[i][dividercounter] = converted;

      dividercounter += 1;
    }
  }

  // return a single coordinate by input parameters

  if (set == "paths") {
    result = final_paths[shape][coordinate];
  }
  if (set == "polys") {
    result = final_polys[shape][coordinate];
  }

  return result;

}


/* Function that draws the svg paths */

void svgDraw() {


}