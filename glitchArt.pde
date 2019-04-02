/*----------------------------------------
|    Interactive Glitch Art Filter        |
|      Coded by: Erik Dillaman            |
 ----------------------------------------*/

import processing.serial.*;
import cc.arduino.*;
import org.firmata.*;

Arduino arduino;
int r, g, b, pot1, pot2;
int mX, mY;
PImage img, img2, imgRed, imgGreen, imgBlue;
String fileName = "image3.png";
float noiseScale;
float waveLength = 100; 
boolean newShift;

boolean DEBUG = false;

void setup()
{
  img = loadImage(fileName);
  img2 = loadImage(fileName);
  imgRed = loadImage(fileName);
  imgGreen = loadImage(fileName);
  imgBlue = loadImage(fileName);
  arduino = new Arduino(this, Arduino.list()[2], 57600);
  arduino.pinMode(3, Arduino.INPUT);
  arduino.pinMode(5, Arduino.INPUT);
  arduino.pinMode(6, Arduino.INPUT);

  r = 0;
  g = 0;
  b = 0;
  mX = mouseX;
  mY = mouseY;
  newShift = true;
  surface.setSize(img.width, img.height);
  pixelDensity(2);
}


void draw()
{
  arduino.analogWrite(9, r);
  arduino.analogWrite(10, g);
  arduino.analogWrite(11, b);
  noiseScale = map(arduino.analogRead(2), 0, 1023, .001, .5); 
  
  img.loadPixels();
  img2.loadPixels();
  imgRed.loadPixels();
  imgGreen.loadPixels();
  imgBlue.loadPixels();
  background(255);

  colorShift();
  perlinStatic();  
}

void colorShift()
{
  int nX, nY;
  
  if(arduino.analogRead(1) > 0){
    nX = (int)(noise(arduino.analogRead(1))*200);
    nY = (int)(noise(arduino.analogRead(1)*2)*200);
  } else {
    nX = 0;
    nY = 0;
  }

  for (int y = 0; y < imgRed.height; y++) {
    for (int x = 0; x < imgRed.width; x++) {  
      int index = y*imgRed.width+x;
      int noiseIndex = ((y+nY)%imgRed.height)*imgRed.width + ((x+nX)%imgRed.width); 
      imgRed.pixels[index] = color(red(img2.pixels[noiseIndex]), green(img2.pixels[noiseIndex]), 0, abs(255*(noise(x*noiseScale*4, y*noiseScale*3))));
    }
  }

  for (int y = 0; y < imgGreen.height; y++) {
    for (int x = 0; x < imgGreen.width; x++) {  
      int index = y*imgGreen.width+x;
      int noiseIndex = abs((y-nY)%imgGreen.height)*imgGreen.width + abs((x-nX)%imgGreen.width); 
      imgGreen.pixels[index] = color(0, green(img2.pixels[noiseIndex]), blue(img2.pixels[noiseIndex]), abs(255*(noise(x*noiseScale*1.4, y*noiseScale*2))));
    }
  }

  for (int y = 0; y < imgBlue.height; y++) {
    for (int x = 0; x < imgBlue.width; x++) {  
      int index = y*imgBlue.width+x;
      int noiseIndex = abs((y+nY)%imgBlue.height)*imgBlue.width + abs((x-nX)%imgBlue.width); 
      imgBlue.pixels[index] = color(red(img2.pixels[noiseIndex]), 0, blue(img2.pixels[noiseIndex]), abs(255*(noise(x*noiseScale, y*noiseScale))));
    }
  }
   
  imgRed.updatePixels();
  imgGreen.updatePixels();
  imgBlue.updatePixels();
  image(imgRed, 0, 0);
  image(imgGreen, 0, 0);
  image(imgBlue, 0, 0);
}

void perlinStatic()
{

  for (int y = 0; y < img.height; y++) {  //  Y FOR LOOP
    float noiseVal = noise(y*(1/waveLength));
    color[] rowCopy = new color[img.width];    

    for (int x = 0; x < img.width; x++) {   //  X FOR LOOP 1
      int index = y*img.width+x;
      rowCopy[x] = img.pixels[index];
    }
    int perlin = (int)(noiseVal*arduino.analogRead(0));
    for (int x = 0; x < img.width; x++) {   //  X FOR LOOP 2
      int index = y*img.width+x;
      img.pixels[index] = rowCopy[(perlin+x)%img.width];
      img.pixels[index] = color(red(img.pixels[index]), green(img.pixels[index]), blue(img.pixels[index]), 255-(noise(x*noiseScale, y*noiseScale)*map(arduino.analogRead(1), 0, 1023, 0, 255)));
    }
  }
  img.updatePixels();
  image(img, 0, 0);
  setRGB();
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = img2.pixels[i];
  }
}

void setRGB()
{
  int index = mouseY*img.width+mouseX;
  r = (int)red(img.pixels[index]);
  g = (int)green(img.pixels[index]);
  b = (int)blue(img.pixels[index]);
  if(DEBUG) println("R: "+r+"   G: "+g+"   B: "+b);
  mX = mouseX;
  mY = mouseY;
}
