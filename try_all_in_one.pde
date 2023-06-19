// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain
// Code for: https://youtu.be/nCVZHROb_dE
import processing.video.*;
import processing.serial.*;
Serial port ;
Capture video;
color trackColor; 
float threshold = 30;
int rX = 105;
int rY = 80;
////////////////////////////PID/////////////////
float referencePosX = 90;
float referencePosY = 90;
float lastErrX = 0;
float lastErrY = 0;
float ErrorSumX = 0;
float ErrorSumY = 0;
float currentX = 0;
float currentY = 0;
float currentErrX;
float currentErrY;
float outputX;
float outputY;
float finX = 0;
float finY = 0;
float Kpx = 0.18;
float Kix = 0.20;
float Kdx = 0.20;
float Kpy = 0.20;
float Kiy = 0.20;
float Kdy = 0.25;
int sampleTime = 50;
long lastTime = 0;
float tempX = referencePosX;
float tempY = referencePosY;
float k[] = new float[3];
Handle[] handles;


void setup() {
  size(800, 480);
  lastTime = millis();
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, 640, 480);
  video.start();
  trackColor = color(255, 0, 0);
  int num = 3;
  handles = new Handle[num];
  int hsize = 10;
  for (int i = 0; i < handles.length; i++) {
    handles[i] = new Handle(video.width, 10+i*15, 50-hsize/2, 10, i, handles);
  }
  String portName = Serial.list()[0];
  port = new Serial (this, portName, 115200);
}

void captureEvent(Capture video) {
  video.read();
}

void draw() {
  long currentTime = millis();
  background(153);
  strokeWeight(1);
  stroke(0);
  fill(0);
  for (int i = 0; i < handles.length; i++) {
    handles[i].update();
    //k[i] = handles[i].put();
    handles[i].display();
  }
  Kpx = k[0];
  Kix = k[1];
  Kdx = k[2];
  Kpy =Kpx;
  Kiy =Kix;
  Kdy =Kdx;
  textSize(15);
  text("Kp= ", 650, 100);
  text(Kpx, 700, 100);
  text("Ki= ", 650, 130);
  text(Kix, 700, 130);
  text("Kd= ", 650, 160);
  text(Kdx, 700, 160);

  //print( Kpx);
  //print( Kix);
  //println( Kdx);

  video.loadPixels();
  image(video, 0, 0);
  line(video.width/2, 0, video.width/2, video.height);
  line(0, video.height/2, video.width, video.height/2);

  //threshold = map(mouseX, 0, width, 0, 100);
  int avgX = 0;
  int avgY = 0;
  int count = 0;
  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int loc = x + y * video.width;
      // What is current color
      color currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      float d = distSq(r1, g1, b1, r2, g2, b2); 

      if (d < threshold*threshold) {
        stroke(255);
        strokeWeight(1);
        point(x, y);
        avgX += x;
        avgY += y;
        count++;
      }
    }
  }

  // We only consider the color found if its color distance is less than 10. 
  // This threshold of 10 is arbitrary and you can adjust this number depending on how accurate you require the tracking to be.
  if (count > 50) { 
    avgX = avgX / count;
    avgY = avgY / count;
    // Draw a circle at the tracked pixel
    fill(255);
    strokeWeight(4.0);
    stroke(0);
    ellipse(avgX, avgY, 24, 24);
    port.write(str(int(finX))+','+str(int(finY))+'.'); 
    text("outputX= ", 650, 190);
    text(int(finX), 720, 190);
    text("outputY= ", 650, 210);
    text(int(finY), 720, 210);
    //println(str(int(finX))+','+str(int(finY))+'.');
    if ( currentTime - lastTime >= sampleTime ) {
      lastTime = currentTime;
      currentX = map(avgX, 0, 640, 0, 180);
      currentY = map(avgY, 0, 480, 0, 180);
      control();
      //println(currentTime);
    }
  } 
  else {   
    port.write(str(rX)+','+str(rY)+'.'); 
    text("outputX= ", 650, 190);
    text(rX, 720, 190);
    text("outputY= ", 650, 210);
    text(rY, 720, 210);
    //println(str(rX)+','+str(rY)+'.');
  }
}
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  if ( mouseX < video.width) {
    int loc = mouseX + mouseY*video.width;
    trackColor = video.pixels[loc];
  }
}
void mouseReleased() {
  for (int i = 0; i < handles.length; i++) {
    handles[i].releaseEvent();
  }
}