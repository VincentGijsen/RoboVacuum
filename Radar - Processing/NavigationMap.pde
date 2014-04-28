
class NavigationMap {

  public final static int OBSTACLE = 0x01;
  public final static int CLEAR = 0x02;
  public final static int VISITED = 0x04;

  public int MAP_SIZE_X;
  public int MAP_SIZE_Y;
  public float MAP_TO_DISTANCE_RATIO = 1; //denotes the distance measured mapped to mapentries

  private int [][] map;
  private int DISPLAY_TIME = 1000;
  int _lastTime;

  PImage img;

  NavigationMap(int sizeX, int sizeY, float ratio) {
    MAP_SIZE_X = sizeX;
    MAP_SIZE_Y = sizeY;
    MAP_TO_DISTANCE_RATIO = ratio;
    map= new int[MAP_SIZE_X][MAP_SIZE_Y];
    img = createImage(sizeX, sizeY, ALPHA);



    clearMap();
    _lastTime = millis();
  }




  void clearMap() {
    for (int x=0; x<  MAP_SIZE_X; x++) {
      for (int y=0; y< MAP_SIZE_Y; y++) {
        map[x][y] = CLEAR;
        img.pixels[x + y*MAP_SIZE_Y] = color(243);
      }
    }
  }

  void display() {
    int xOffset = 400;
    int yOffset = 500;   
    image(img, xOffset, yOffset);
  }

  /*
  void display() {
   
   
   
   int xOffset = 400;
   int yOffset = 500;
   translate(xOffset, yOffset);
   for (int x=0; x<MAP_SIZE_X; x++) {
   for (int y=0; y<MAP_SIZE_Y; y++) {
   
   switch(map[x][y])
   {
   case OBSTACLE:
   fill(10, 100, 10);
   break;
   case CLEAR:
   fill(200);
   break;
   default:
   fill(20);
   break;
   }
   print("x ", x);
   print(" y ", y);
   println(" map[x][y]", map[x][y]);
   point(x, y);
   }
   }
   
   //restore translate
   translate(-xOffset, -yOffset);
   }
   
   */
  /**
   UPdates the map based on present coordinates
   **/
  void update(int servoPosition, int distance, int robotX, int robotY) {
    float circleAngle = map(servoPosition, 0, 180, 0, PI);
    
    int xPoint =(int) (robotX + (cos(circleAngle) * distance * MAP_TO_DISTANCE_RATIO));
    int yPoint =(int) (robotY + (sin(circleAngle) * distance * MAP_TO_DISTANCE_RATIO));

    if (xPoint > MAP_SIZE_X)
      xPoint = MAP_SIZE_X-1;

    if (yPoint > MAP_SIZE_Y)
      yPoint = MAP_SIZE_Y-1;

    if (xPoint < 0)
      xPoint = 0;

    if (yPoint < 0)
      yPoint = 0;
    
    map[xPoint][yPoint] = OBSTACLE;
    int pixel = xPoint + yPoint * MAP_SIZE_Y;
    println("updated map", xPoint, yPoint, pixel);
    img.set(xPoint, yPoint, color(0));
  }
}

