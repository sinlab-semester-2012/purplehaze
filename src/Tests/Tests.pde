import codeanticode.gsvideo.*;
import monclubelec.javacvPro.*;


GSCapture cam;
OpenCV opencv;

int widthCapture = 320;
int heightCapture = 240;
int fpsCapture = 15;

Blob[] blobs;
float prevblob0x;
float prevblob0y;

DynEllipse dynEllipse;

void setup() {
    colorMode(RGB, 255, 255, 255);
    fill(0, 0, 255);
    stroke (0, 0, 255);
    rectMode(CORNER);
    imageMode(CORNER);
    ellipseMode(CENTER);
    frameRate(30);

    size(widthCapture*2,heightCapture*2);
    background(0);
    
    cam = new GSCapture(this, widthCapture, heightCapture, fpsCapture);
    cam.start();
    opencv = new OpenCV(this);
    opencv.allocate(widthCapture, heightCapture);
    
    dynEllipse = new DynEllipse();
}

void draw() {
    if (cam.available()) {
        cam.read();
        opencv.copy(cam.get());
        
        opencv.blur();
        image(opencv.image(), 0, 0);
        opencv.absDiff();
        image(opencv.getMemory2(), 0, heightCapture);
        opencv.threshold(opencv.Memory2, 0.2, "BINARY");
        image(opencv.getMemory2(), widthCapture, heightCapture);
        
        blobs = opencv.blobs(opencv.Memory2, opencv.area()/64, opencv.area(), 10, false, 4096, false);
        
        fill(0, 0, 255);
        stroke (0, 0, 255);
        rectMode(CORNER);
        imageMode(CORNER);
        ellipseMode(CENTER);
        opencv.drawRectBlobs(blobs, opencv.width(), opencv.height(), 1);
        opencv.drawBlobs(blobs, opencv.width(), opencv.height(), 1 );
        opencv.drawCentroidBlobs(blobs, opencv.width(), opencv.height(), 1);
    }
    
    drawDynEli();
    //drawMouseDynEli();
}

void drawDynEli() {
    float offset = 5;
    if (blobs != null && blobs.length > 0) {
        if (abs(blobs[0].centroid.x - prevblob0x) > offset || abs(blobs[0].centroid.y - prevblob0y) > offset) {
            dynEllipse.generateDynEllipse();
        }
        dynEllipse.drawDynEllipse(blobs[0].centroid.x, blobs[0].centroid.y);
        prevblob0x = blobs[0].centroid.x;
        prevblob0y = blobs[0].centroid.y;
    }
}

void drawMouseDynEli() {
    float offset = 5;
    if (abs(mouseX - pmouseX) > offset || abs(mouseY - pmouseY) > offset) {
        dynEllipse.generateDynEllipse();
    }
    dynEllipse.drawDynEllipse(mouseX, mouseY);
}

void keyPressed() {
    if (key == ' ') {
        opencv.remember();
        image(opencv.getMemory(), widthCapture, 0);
    }
}

