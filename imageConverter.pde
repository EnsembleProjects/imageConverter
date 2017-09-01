PImage originals[];  //storing the images like this isn't actually necessary, just for debug drawing
PImage converted[];

int cAryWid = 12;
int cAryHei = 10;
int windWid = 360;   //height determined automatically to fit 12:10 ratio
  
String oriPath = "racecourse/cropped/";
String[] fNames = {"0000", "0300", "1200", "1500", "1800", "2100"};

/**
  All of the work the program is meant for happens here.
  i.e. This is where each image is loaded, converted, and subsequently saved
*/
void setup(){
  surface.setSize(windWid, int(windWid/1.2));
  println("window width: " + width + "\nwindow height: " + height);
  
  originals = new PImage[fNames.length];
  converted = new PImage[fNames.length];
  for (int i = 0; i < originals.length; i++){
    originals[i] = loadImage(oriPath + fNames[i] + ".png");
    converted[i] = deRes(originals[i]);
    //String outName = (oriPath + "output/out_" + fNames[i] + ".png");
    converted[i].save("C:/Users/JETho/Documents/Processing/edCode/PROJ_imgIntoClipArray/imgIntoClipArray_v4_2/output/pixels" + (i+1) + ".png");
  }
}

int i = 0;
boolean click = false;
/**
  For debug purposes only, draws enlarged versions of the converted images to the screen.
  Clicking the mouse allows traversal between the images.
*/
void draw(){
  background(255);
  //image(converted[i], 0, 0);
  drawEnlarged(converted[i]);
  if (mousePressed && !click){
    i++;
    if (i >= converted.length) i = 0;
    click = true;
  }
} 

void mouseReleased(){
  click = false;
}

/**
  For debug purposes only, draws enlarged versions of the converted images to the screen.
  Clicking the mouse allows traversal between the images.
*/
PImage deRes(PImage ori){
  ori.loadPixels();
  
  //below try to detect incorrect ratios, however sometimes trying to use incorrect ratios will just cause a crash anyway; so best not to.
  float imgRatio = float(ori.width)/float(ori.height);
  if (imgRatio != float(cAryWid)/float(cAryHei)) println("Ratio not correct, clip mapping will contain errors\nImage ratio = " + imgRatio); 
  
  int pixPerX = ori.height/cAryHei;   //how many pixels will make up the width and height of each quadrant
  int pixPerY = ori.width/cAryWid;
  
  //println("ppX: " + clipWidOutput + " | ppY: " + clipHeiOutput);  
  color[] avgCols = new color[cAryWid*cAryHei];      //this will be the key output of the function
  PImage newImg = createImage(12, 10, RGB);          //makes a new image to store these avgCols into once they are found
  newImg.loadPixels();
  
  int outerCount = 0;                                //used to address the quadrant
  for (int bigY = 0; bigY < cAryHei; bigY++){        //'big' Y and X refer to the co-ordinates of the quadrants (clips) as a whole, not the pixels within
    for (int bigX = 0; bigX < cAryWid; bigX++){
      float totR = 0, totB = 0, totG = 0;            //stores total colour variables to sum up every pixel of every clip within the quadrant 
      int scaleX = bigX*pixPerX;                     //used to offset the pixel on the x axis we are addressing to the quadrant we're in 
      int innerCount = 0;                            //used as an pixel index from within the quadrant
      for (int y = 0; y < pixPerY; y++){
        int rowStart = scaleX + y*ori.width;         //the start of the row (x=0) given a y value  
        int scaleY = bigY*pixPerY;                   //same as scaleX^ but for Y
        for (int x = 0; x < pixPerX; x++){
          //(below) former part works out the pNum of the row/y (scaled to whole image)
          int pNum = (scaleY*ori.width) + (rowStart+x);  //latter part finds x = pNum if whole array was size of 1 clip, 'rowStart' scales it up to actual array size
          //println("pix num: " + pNum);
          color pCol = ori.pixels[pNum];
          //println(" | red: " + red(pCol) + " | green: " + blue(pCol) + " | blue: " + green(pCol));
          //if (!(red(pCol) == 255 && green(pCol) == 255 && blue(pCol) == 255)){  //doesn't count avg of clear blocks
            totR = totR + red(pCol);
            totG = totG + green(pCol);
            totB = totB + blue(pCol);
            innerCount++;
          //}
          
        }
      }
      float avgR = totR/innerCount;
      float avgG = totG/innerCount;
      float avgB = totB/innerCount;
      //println("red: " + avgR + " | green: " + avgG + " | blue: " + avgB);
      avgCols[outerCount] = color(avgR, avgG, avgB);
      //if (!(avgR == 255 && avgG == 255 && avgB == 255)){ //ONLY if they're not pure white are they added
        newImg.pixels[outerCount] = avgCols[outerCount];
      //}
      //println("Clip " + outerCount + ": " + avgB);
      //println("x: " + bigX*pixPerX + " | y: " + bigY*pixPerY);
      outerCount++;
    }
  }
  return newImg;
}

/**
  Takes a converted image and enlarges it to the size of the window
*/
void drawEnlarged(PImage img){
  int clipWidOut = width/cAryWid;
  int clipHeiOut = height/cAryHei;
  
  img.loadPixels();
  noStroke();
  for (int i = 0; i < img.pixels.length; i++){
    int x = i % 12;
    int y = (i/12) % 10;
    //println(i + " | x: " + x + " | y: " + y);
    fill(img.get(x, y));
    rect(x*clipWidOut, y*clipHeiOut, clipWidOut, clipHeiOut);
  }
}