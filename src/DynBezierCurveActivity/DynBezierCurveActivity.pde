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
static final int OCVDD_NONE = 0;
static final int OCVDD_BLURRED_CAPTURED = 1;
static final int OCVDD_REFRERENCE = 2;
static final int OCVDD_ABS_DIFF = 3;
static final int OCVDD_THRESHOLDED = 4;
static final int OCVDDSIZE = 5;
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
    
    opencvDebugDisplay = OCVDD_NONE;
    blobDebugDisplay = false;
}

void draw() {
    background(0);
    
    if (cam.available()) {
        cam.read();
        opencv.copy(cam.get());
        
        opencv.blur();
        if (opencvDebugDisplay == OCVDD_BLURRED_CAPTURED) {
            image(opencv.image(), 0, 0);
            fill(255, 255, 0);
            text("blurred captured", 10, 20);
        }
        if (opencvDebugDisplay == OCVDD_REFRERENCE) {
            image(opencv.getMemory(), 0, 0);
            fill(255, 255, 0);
            text("reference", 10, 20);
        }
        opencv.absDiff();
        if (opencvDebugDisplay == OCVDD_ABS_DIFF) {
            image(opencv.getMemory2(), 0, 0);
            fill(255, 255, 0);
            text("abs diff", 10, 20);
        }
        opencv.threshold(opencv.Memory2, 0.2, "BINARY");
        if (opencvDebugDisplay == OCVDD_THRESHOLDED) {
            image(opencv.getMemory2(), 0, 0);
            fill(255, 255, 0);
            text("thresholded", 10, 20);
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
    opencvDebugDisplay = (opencvDebugDisplay + 1) % OCVDDSIZE;
}

void toggleBlobDebugDisplay() {
    blobDebugDisplay = !blobDebugDisplay;
}

void keyPressed() {
    if (key == ' ') {
        if (dynBezierCurve.isInInitState()) {
            opencv.remember();
            dynBezierCurve.launch();
        }
    } else if (key == ENTER || key == RETURN) {
        dynBezierCurve.reset();
    } else if (key == '-') {
        dynBezierCurve.decreaseNbPoints();
    } else if (key == '+') {
        dynBezierCurve.increaseNbPoints();
    } else if (key == '.') {
        dynBezierCurve.toggleDebugDisplay();
    } else if (key == '/') {
        toggleOpencvDebugDisplay();
    } else if (key == '*') {
        toggleBlobDebugDisplay();
    }
}

