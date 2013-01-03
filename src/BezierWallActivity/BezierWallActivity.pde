import codeanticode.gsvideo.*;
import krister.Ess.*;
import monclubelec.javacvPro.*;

int widthScreen = 640;
int heightScreen = 480;
int fps = 30;

int widthCapture = 640;
int heightCapture = 480;
int fpsCapture = 30;

GSCapture cam;
OpenCV opencv;
Blob[] blobs;

int opencvDebugDisplay;
static final int OCVDD_NONE = 0;
static final int OCVDD_BLURRED_CAPTURED = 1;
static final int OCVDD_REFRERENCE = 2;
static final int OCVDD_ABS_DIFF = 3;
static final int OCVDD_THRESHOLDED = 4;
static final int OCVDDSIZE = 5;
boolean blobDebugDisplay;

BezierWall bezierWall;

void setup() {
    // initialize screen
    size(widthScreen, heightScreen);
    background(0);
    smooth();
    frameRate(fps);
    
    // initialize and start cam
    cam = new GSCapture(this, widthCapture, heightCapture, fpsCapture);
    cam.start();
    opencv = new OpenCV(this);
    opencv.allocate(widthCapture, heightCapture);
    
    // initialize visual debug variables
    opencvDebugDisplay = OCVDD_NONE;
    blobDebugDisplay = false;
    
    // initialize sound manager
    Ess.start(this);
    
    // initialize Bezier wall
    bezierWall = new BezierWall(2);
}

void draw() {
    background(0);
    
    if (cam.available()) {
        // read image from cam
        cam.read();
        opencv.copy(cam.get());
        
        // blur captured image
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
        // compute absolute difference with current image
        opencv.absDiff();
        if (opencvDebugDisplay == OCVDD_ABS_DIFF) {
            image(opencv.getMemory2(), 0, 0);
            fill(255, 255, 0);
            text("abs diff", 10, 20);
        }
        // do binary thresholding on image
        opencv.threshold(opencv.Memory2, 0.2, "BINARY");
        if (opencvDebugDisplay == OCVDD_THRESHOLDED) {
            image(opencv.getMemory2(), 0, 0);
            fill(255, 255, 0);
            text("thresholded", 10, 20);
        }
        
        // detect blobs on thresholded image
        blobs = opencv.blobs(opencv.Memory2, opencv.area()/64, opencv.area(), 10, false, 4096, false);
        
        if (blobDebugDisplay) {
            opencv.drawRectBlobs(blobs, 0, 0, 1);
            opencv.drawBlobs(blobs, 0, 0, 1 );
            opencv.drawCentroidBlobs(blobs, 0, 0, 1);
        }
    }
    
    // update Bezier wall
    bezierWall.draw();
    bezierWall.move();
    bezierWall.interact(blobs);
}

void toggleOpencvDebugDisplay() {
    opencvDebugDisplay = (opencvDebugDisplay + 1) % OCVDDSIZE;
}

void toggleBlobDebugDisplay() {
    blobDebugDisplay = !blobDebugDisplay;
}

void keyPressed() {
    if (key == ' ') {
        if (bezierWall.isInInitState()) {
            opencv.remember();
            bezierWall.launch();
        }
    } else if (key == ENTER || key == RETURN) {
        bezierWall.reset();
    } else if (key == '-') {
        bezierWall.decreaseNbPoints();
    } else if (key == '+') {
        bezierWall.increaseNbPoints();
    } else if (key == '.') {
        bezierWall.toggleDebugDisplay();
    } else if (key == '/') {
        toggleOpencvDebugDisplay();
    } else if (key == '*') {
        toggleBlobDebugDisplay();
    }
}

