#define DISTANCESAMPLES 1

#define trigPin 3
#define echoPin 2
#define led 7
#define led2 3
#define servoPin 4

#define SERVOMIN 20
#define SERVOMAX 160
#define SERVOINCREMENT 5
#define STEPSLEEP 100


/*
Commands
 */
#define START_RADAR 0x01
#define STOP_RADAR 0x02

#define MOVE_PLUS_1 0x03
#define MOVE_MINUS_1 0x04


#include <Servo.h>

Servo myServo;

int direction = 0;
int position = SERVOMIN;

int _radarActive = 0;

void setup() {
  Serial.begin (9600);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(led, OUTPUT);
  pinMode(led2, OUTPUT);

  myServo.attach(servoPin);
}

int measure(){
  long duration, distance;
  digitalWrite(trigPin, LOW);  // Added this line
  delayMicroseconds(2); // Added this line
  digitalWrite(trigPin, HIGH);
  //  delayMicroseconds(1000); - Removed this line
  delayMicroseconds(10); // Added this line
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance = (duration/2) / 29.1;
  if (distance >= 200 || distance <= 0){
    distance = 0;
  }
  return distance;
}


void loop() {
  //handles rs232 stuff
  handleCommands();
  
  //handles radar active
  if (_radarActive){
    delay(STEPSLEEP);
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

    int cnt = 0;
    long avg = 0;

    for (int x=0; x< DISTANCESAMPLES; x++){
      int buff = measure();
      if (buff > 0){
        avg += buff;
        cnt++;
      }

    }

    int val = (int) (avg/cnt);
    Serial.print("|");
    Serial.write(position);
    Serial.print(",");
    Serial.write(val);
    Serial.write('\n');
    //  Serial.println(" degree");
  }
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
      Serial.print("got" + incomingByte);
      break;


    }
  }

}




