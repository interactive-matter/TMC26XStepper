//our graph dimensions
int plotBottom, plotTop;
int plotLeft, plotRight;


//we already know the minima and maxima of certain dates
int stallGuardMin =  0;
int stallGuardMax =1023;

int positionMin = -512;
int positionMax = 512;

int dataPointsWidth = 5;
color stallGuardColor = #ff0000;
color positionColor = #00ff00;

int numberOfDataPoints=100;

DataTable stallGuardTable = new DataTable(numberOfDataPoints);
DataTable positionTable = new DataTable(numberOfDataPoints);

color graphBackgroundColor = #ffffff;

void setupData() {
  plotBottom = height-50;
  plotTop = 150;

  plotLeft = 50;
  plotRight= width-plotLeft;
}

void drawData() {

  fill(graphBackgroundColor);
  rectMode(CORNERS);
  noStroke();
  rect(plotLeft, plotBottom, plotRight, plotTop);

  strokeWeight(dataPointsWidth);
  stroke(stallGuardColor);
  drawData(stallGuardTable, stallGuardMin, stallGuardMax);
  stroke(positionColor);
  drawData(positionTable, positionMin, positionMax);
}

void drawData(DataTable table, int minValue, int maxValue) {
  int dataCount = table.getSize();
  for (int i=0; i<dataCount; i++) {
    int value = table.getEntry(i);
    float x = map(i, 0, numberOfDataPoints-1, plotLeft, plotRight);
    float y = map(value, minValue, maxValue, plotBottom, plotTop);
    point(x, y);
  }
}

void addStallGuardReading(int value) {
  stallGuardTable.addData(value);
}

void addPositionReading(int value) {
  positionTable.addData(value);
}

