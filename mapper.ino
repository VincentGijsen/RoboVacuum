#define DISTANCESAMPLES 1

#define trigPin 3
#define echoPin 2
#define led 7
#define servoPin 4

#define SERVOMIN 20
#define SERVOMAX 160
#define SERVOINCREMENT 5
#define STEPSLEEP 20
#define DELIM ','

/*
Commands
 */
#define START_RADAR 0x01
#define STOP_RADAR 0x02

#define MOVE_PLUS_1 0x03
#define MOVE_MINUS_1 0x04


#include <Servo.h>

#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_HMC5883_U.h>
#include <NewPing.h>


Adafruit_HMC5883_Unified mag = Adafruit_HMC5883_Unified(12345);

Servo myServo;
NewPing sonar(trigPin, echoPin, 200);

int direction = 0;
int position = SERVOMIN;
float headingDegrees =0;

int _radarActive = 0;

void setup() {
  Serial.begin (38400);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(led, OUTPUT);

  myServo.attach(servoPin);
  if(!mag.begin())
  {
    /* There was a problem detecting the HMC5883 ... check your connections */
    Serial.println("Ooops, no HMC5883 detected ... Check your wiring!");
    while(1);
  }

}

void loop() {
  //the read distance
  int val = 0 ;
  int cnt = 0;
  long avg = 0;

  //handles rs232 stuff
  handleCommands();

  sensors_event_t event; 
  mag.getEvent(&event);
  float heading = atan2(event.magnetic.y, event.magnetic.x);
  // Correct for when signs are reversed.
  if(heading < 0)
    heading += 2*PI;

  // Check for wrap due to addition of declination.
  if(heading > 2*PI)
    heading -= 2*PI;

  // Convert radians to degrees for readability.
  headingDegrees = heading * 180/M_PI; 



  //handles radar active
  if (_radarActive){

    if (direction == 0){
      position+=SERVOINCREMENT;

      if (position >= SERVOMAX){
        direction = 1;
      }  
    }
    else{
      position-=SERVOINCREMENT;

      if (position <= SERVOMIN){
        direction = 0;
      }
    }
    myServo.write(position);
    delay(STEPSLEEP);

  }
  //ping distance  
  val = sonar.ping_cm();

  Serial.print("|");
  Serial.print(DELIM);
  Serial.print(position);
  Serial.print(DELIM);
  Serial.print(val);
  Serial.print(DELIM);
  Serial.print(headingDegrees);
  Serial.print("\n");
  //  Serial.println(" degree");
}

void handleCommands(){
  if(Serial.available()){
    int incomingByte = Serial.read();

    switch(incomingByte){
    case START_RADAR:
      _radarActive = 1;
      break;
    case STOP_RADAR:
      _radarActive = 0;
      break;
    default:
      Serial.println("got" + incomingByte);
      break;


    }
  }

}








