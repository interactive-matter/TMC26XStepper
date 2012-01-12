//our graph dimensions
int plotBottom, plotTop;
int plotLeft, plotRight;


//we already know the minima and maxima of certain dates
int stallGuardMin =  0;
int stallGuardMax =1023;

int positionMin = -512;
int positionMax = 512;

int dataPointsWidth = 5;

color graphBackgroundColor = #131313;
color stallGuardColor = #8c1c3d;
color positionColor = #1a6699; //still to use #1a9933

int numberOfDataPoints=100;

DataTable stallGuardTable = new DataTable(numberOfDataPoints);
DataTable positionTable = new DataTable(numberOfDataPoints);


void setupData() {
  plotBottom = height-20;
  plotTop = 150;

  plotLeft = 20;
  plotRight= width-plotLeft;
}

void drawData() {

  fill(graphBackgroundColor);
  rectMode(CORNERS);
  noStroke();
  rect(plotLeft, plotBottom, plotRight, plotTop);

  strokeWeight(dataPointsWidth);
  stroke(positionColor);
  drawData(positionTable, positionMin, positionMax);
  stroke(stallGuardColor);
  drawData(stallGuardTable, stallGuardMin, stallGuardMax);
}

void drawData(DataTable table, int minValue, int maxValue) {
  int dataCount = table.getSize();
  for (int i=0; i<dataCount; i++) {
    int value = table.getEntry(i);
    float x = map(i, 0, numberOfDataPoints-1, plotLeft+dataPointsWidth, plotRight-dataPointsWidth);
    float y = map(value, minValue, maxValue, plotBottom-dataPointsWidth, plotTop+dataPointsWidth);
    point(x, y);
  }
}

void addStallGuardReading(int value) {
  stallGuardTable.addData(value);
}

void addPositionReading(int value) {
  positionTable.addData(value);
}

