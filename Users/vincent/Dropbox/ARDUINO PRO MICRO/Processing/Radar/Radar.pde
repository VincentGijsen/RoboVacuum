/**
 * Simple Read
 * 
 * Read data from the serial port and change the color of a rectangle
 * when a switch connected to a Wiring or Arduino board is pressed and released.
 * This example works with the Wiring / Arduino program that follows below.
 */






import processing.serial.*;
import java.util.Map;


color bgcolor = color (0, 0, 0);
color gridcolor = color (0, 0, 0);
color sweepercolor = color (102, 250, 81);
float s;
float rond;

//compass
float angle;
PFont b;


/*
Commands
 */
public final static  int START_RADAR =  0x01;
public final static  int  STOP_RADAR = 0x02;

public final static  int MOVE_PLUS_1 = 0x03;
public final static  int MOVE_MINUS_1 = 0x04;



HashMap<Integer, Integer> distances = new HashMap<Integer, Integer>();

int l;

//radar definitie
int xradar = 200;
int yradar = 200;
int radarSize = 300;


Serial myPort;  // Create object from Serial class
int val;      // Data received from the serial port
int position;
int distance;

void setup() 
{
  size(900, 768);
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  println(Serial.list());
  String portName = Serial.list()[0];
  myPort = new Serial(this, "/dev/tty.usbmodem1411", 9600);
  //myPort = new Serial(this, "/dev/tty.Bluetooth-Modem", 9600);
}

void draw()
{
  if (myPort != null) {
    if ( myPort.available() > 0) {  // If data is available,
      delay(3); 
      int c = myPort.read();
      if (c == '|') { //sync byte
        position = myPort.read();
        myPort.read(); //read separator
        distance = myPort.read();
        myPort.read(); //read newline char

        distances.put(position, distance); 
        print(position);
        print(" - = ");
        println(distance);
      }
    }
  }
  //DemoData
  else {
    distances.put(0, 0);
    distances.put(5, 30);
    distances.put(10, 30);
    distances.put(15, 34);
    distances.put(20, 35);
    distances.put(25, 37);

    distances.put(90, 75);
    distances.put(160, 26);
    distances.put(163, 180);
    distances.put(165, 180);
  }

  background(bgcolor);
  grid(); 
  sweeper();
  circle();
  drawHistoryPoints();
  drawCompass();
  //translate();
  //stipje();

  drawButton( 10, 400, 50, "Start Radar", START_RADAR);
}



void circle() {
  //draw cirlcle
  fill(color (102, 250, 81, 60));
  //  x    y    xsize ysize
  ellipse(xradar, yradar, radarSize, radarSize);
  stroke(#FAF7F7);
  strokeWeight(2);

  line(xradar, 
  yradar, 
  xradar, 
  yradar-radarSize/2);            //verticlal grid

  line(xradar - radarSize/2, 
  yradar, 
  xradar + radarSize/2, 
  yradar);          //horizontal grid

  //
  for (int i = 0; i <radarSize; i+=20) {
    line((xradar)+5, i+(yradar - radarSize/2), (xradar)-5, i + (yradar  - radarSize/2));
  }

  //draw vertical stripes on horzontal-axis 
  for (int i = 700; i >400; i-=20) {
    //  line(i, (height/2)+5,i,(height/2)-5 );
  }
}

void drawHistoryPoints() {
  //drawOldValues
  stroke(#FFFFFF);
  strokeWeight(2);



  for (int x=0; x< 180;x++) {
    Integer val = distances.get(x);
    if (val != null) {
      println("val ==", val);
      float circleAngle = map(x, 0, 180, 0, PI);
      float vectorLength = map(val, 0, 180, 0, radarSize/2);
      println("rond: " + rond);
      println("vectorSize: ", vectorLength);
      l = 200;
      float xCoor = xradar - (cos(circleAngle) * vectorLength);
      float yCoor = yradar - (sin(circleAngle) * vectorLength);
      println("calculated: " +  val + " " + xCoor + " " + yCoor);
      ellipse(xCoor, yCoor, 5, 5);
      // println("rendering history point: ", val, " - " , rond, " - - ");
    }
  }
}




void sweeper() {
  rond = map(position, 0, 180, 0, PI);
  strokeWeight(7);
  float f = 0.01;

  int l = distance *2;
  for (int i = 2; i>=1; i--) {
    stroke(sweepercolor, 2*i);
    //duration was 300
    line(xradar, yradar, (xradar - cos(rond-f) * l), (yradar - sin(rond-f) * l));
    f += 0.01;
  }
}


void grid() {
}


void stipje() {
  int n = 200;
  ellipse(position, 10, 20, 20);
}


void drawCompass() {
  // draw the compass background
  ellipseMode(CENTER);
  fill(50);
  stroke(10);
  strokeWeight(2);
  ellipse(xradar + 400, yradar, 300, 300);

  // draw the lines and dots
  translate(xradar + 400, yradar);  // translate the lines and dots to the middle of the compass
  float CompassX = -angle;
  rotate(radians(CompassX));
  noStroke();
  fill(51, 255, 51);

  int radius = 120;

  for ( int degC = 5; degC < 360; degC += 10) //Compass dots
  {
    float angleC = radians(degC);
    float xC = 0 + (cos(angleC)* radius);
    float yC = 0 + (sin(angleC)* radius);
    ellipse(xC, yC, 3, 3);
  }

  for ( int degL = 10; degL < 370; degL += 10) //Compass lines
  {
    float angleL = radians(degL);
    float x = 0 + (cos(angleL)* 145);
    float y = 0 + (sin(angleL)* 145);

    if ( degL==90 || degL==180 || degL==270 || degL==360) {
      stroke(51, 255, 51);
      strokeWeight(4);
    }
    else {
      stroke(234, 144, 7);
      strokeWeight(2);
    }
    line(0, 0, x, y);
  }

  fill(102, 102, 102); 
  noStroke();
  ellipseMode(CENTER);
  ellipse(0, 0, 228, 228); //draw a filled circle to hide the lines in the middle

  b = loadFont("Monospaced-48.vlw");
  textAlign(CENTER);

  // Draw the letters
  fill(250);
  textFont(b, 32);
  text("N", 1, -90);
  rotate(radians(90));
  text("E", 0, -90);
  rotate(radians(90));
  text("S", 0, -90);
  rotate(radians(90));
  text("W", 0, -90);
  rotate(radians(90));

  textFont(b, 40);
  textAlign(CENTER);
  text((angle), 20, 20);
  // println(angle);

  //draw the needle

  rotate(radians(-CompassX)); //make it stationary
  stroke(234, 144, 7);
  strokeWeight(3);

  triangle(-10, 0, 10, 0, 0, -85);
  fill(234, 144, 7);
  triangle(-10, 0, 10, 0, 0, 60);

  //restore transltate
  translate(-(xradar + 400), - yradar);
}

void drawButton(int x, int y, int size, String text, int action) {
  // background(255);
  rect(x, y, size*2, size);
  fill(200);
  textFont(b, 12);
  text(text, x+size, y+(size/2));
  if (mousePressed) {
    if (mouseX > x && mouseX < x+size*2 && mouseY > y && mouseY < y+size) {
      println("button pressed: ", text);

      myPort.write(action);
      delay(200);
    }
  }
}
