/* Simple one-purpose SVG path & polygon parser  */

void svgParse(String xml_init) {
  XML xml;
  xml = loadXML(xml_init);

  // Initiate final arrays to be exported
  PVector[][] final_paths = new PVector[100][2];
  PVector[][] final_polys = new PVector[100][100];

  // Go through all paths

  XML[] paths = xml.getChildren("g/path");

  for (int i = 0; i < paths.length; ++i) {
    String path = paths[i].getString("d");
    String[] points = split(path, ' ');

    for (int k = 0; k < points.length; ++k) {

      String point = points[k];
      point = point.replace("M", "");
      point = point.replace("L", "");

      String[] coords = split(point, ',');
      float xCoord = Float.parseFloat(coords[0]);
      float yCoord = Float.parseFloat(coords[1]);

      PVector converted = new PVector(xCoord, yCoord);

      final_paths[i][k] = converted;

      println(final_paths[i][k]);

    }

  }

}