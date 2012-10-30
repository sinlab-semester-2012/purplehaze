import codeanticode.gsvideo.*;
import monclubelec.javacvPro.*;


GSCapture cam;
OpenCV opencv;

int widthCapture = 640;
int heightCapture = 480;
int fpsCapture = 30;

Blob[] blobs;
DynBezierCurve dynBezierCurve;

int opencvDebugDisplay;
boolean blobDebugDisplay;

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
    
    opencvDebugDisplay = 0;
    blobDebugDisplay = false;
}

void draw() {
    background(0);
    
    if (cam.available()) {
        cam.read();
        opencv.copy(cam.get());
        
        opencv.blur();
        if (opencvDebugDisplay == 1) {
            image(opencv.image(), 0, 0);
        }
        opencv.absDiff();
        if (opencvDebugDisplay == 2) {
            image(opencv.getMemory2(), 0, 0);
        }
        if (opencvDebugDisplay == 3) {
            image(opencv.getMemory(), 0, 0);
        }
        opencv.threshold(opencv.Memory2, 0.2, "BINARY");
        if (opencvDebugDisplay == 4) {
            image(opencv.getMemory2(), 0, 0);
        }
        
        blobs = opencv.blobs(opencv.Memory2, opencv.area()/64, opencv.area(), 10, false, 4096, false);
        
        if (blobDebugDisplay) {
            opencv.drawRectBlobs(blobs, 0, 0, 1);
            opencv.drawBlobs(blobs, 0, 0, 1 );
            opencv.drawCentroidBlobs(blobs, 0, 0, 1);
        }
    }
    
    dynBezierCurve.draw();
    dynBezierCurve.move();
    dynBezierCurve.interact(blobs);
}

void toggleOpencvDebugDisplay() {
    opencvDebugDisplay = (opencvDebugDisplay + 1) % 5;
}

void toggleBlobDebugDisplay() {
    blobDebugDisplay = !blobDebugDisplay;
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
    } else if (key == 'y') {
        toggleOpencvDebugDisplay();
    } else if (key == 'x') {
        toggleBlobDebugDisplay();
    }
}

