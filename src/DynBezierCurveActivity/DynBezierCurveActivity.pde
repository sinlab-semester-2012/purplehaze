import codeanticode.gsvideo.*;
import monclubelec.javacvPro.*;


GSCapture cam;
OpenCV opencv;

int widthCapture = 640;
int heightCapture = 480;
int fpsCapture = 30;

Blob[] blobs;
DynBezierCurve dynBezierCurve;

void setup() {
    size(widthCapture, heightCapture);
    background(0);
    smooth();
    
    frameRate(fpsCapture);
    cam = new GSCapture(this, widthCapture, heightCapture, fpsCapture);
    cam.start();
    opencv = new OpenCV(this);
    opencv.allocate(widthCapture, heightCapture);
    
    dynBezierCurve = new DynBezierCurve(2);
}

void draw() {
    background(0);
    
    if (cam.available()) {
        cam.read();
        opencv.copy(cam.get());
        
        opencv.blur();
        opencv.absDiff();
        opencv.threshold(opencv.Memory2, 0.2, "BINARY");
        
        blobs = opencv.blobs(opencv.Memory2, opencv.area()/16, opencv.area(), 10, false, 4096, false);
        
        //rectMode(CORNER);
        //ellipseMode(CENTER);
        //opencv.drawRectBlobs(blobs, 0, 0, 1);
        //opencv.drawBlobs(blobs, 0, 0, 1 );
        //opencv.drawCentroidBlobs(blobs, 0, 0, 1);
    }
    
    dynBezierCurve.draw();
    dynBezierCurve.move();
    dynBezierCurve.interact(blobs);
}

void keyPressed() {
    if (key == ' ') {
        opencv.remember();
    } else if (key == ENTER || key == RETURN) {
        dynBezierCurve.reset();
    } else if (key == '.') {
        dynBezierCurve.toggleDebugDisplay();
    } else if (key == '-') {
        dynBezierCurve.decreaseNbPoints();
    } else if (key == '+') {
        dynBezierCurve.increaseNbPoints();
    } else if (key == '*') {
        dynBezierCurve.toggleFixedFirstLastPts();
    }
}

