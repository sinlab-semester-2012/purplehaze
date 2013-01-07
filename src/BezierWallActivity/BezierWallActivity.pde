import codeanticode.gsvideo.*;
import krister.Ess.*;
import monclubelec.javacvPro.*;

int widthScreen = 800;
int heightScreen = 600;
int fps = 30;

int widthCapture = 640;
int heightCapture = 480;
int fpsCapture = 30;

GSCapture cam;

OpenCV opencv;
Blob[] blobs;

BezierWall bezierWall;

int opencvDebugDisplay;
static final int OCVDD_NONE = 0;
static final int OCVDD_BLURRED_CAPTURED = 1;
static final int OCVDD_REFRERENCE = 2;
static final int OCVDD_ABS_DIFF = 3;
static final int OCVDD_THRESHOLDED = 4;
static final int OCVDDSIZE = 5;
boolean blobDebugDisplay;

void setup() {
    // initialize screen
    size(widthScreen, heightScreen);
    background(0);
    smooth();
    frameRate(fps);
    
    // initialize and start cam
    cam = new GSCapture(this, widthCapture, heightCapture, fpsCapture);
    cam.start();
    
    // initialize OpenCV
    opencv = new OpenCV(this);
    opencv.allocate(widthScreen, heightScreen);
    
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
        
        // copy resized image to OpenCV
        PImage camImgResized = cam.get();
        camImgResized.resize(widthScreen, heightScreen);
        opencv.copy(camImgResized);
        
        // blur captured image
        opencv.blur();
        // if corresp. debug mode is on, display blurred image
        if (opencvDebugDisplay == OCVDD_BLURRED_CAPTURED) {
            image(opencv.image(), 0, 0);
            fill(255, 255, 0);
            text("blurred", 10, 20);
        }
        
        // if corresp. debug mode is on, display reference image
        if (opencvDebugDisplay == OCVDD_REFRERENCE) {
            image(opencv.getMemory(), 0, 0);
            fill(255, 255, 0);
            text("reference", 10, 20);
        }
        
        // compute absolute difference with current image
        opencv.absDiff();
        // if corresp. debug mode is on, display abs diff image
        if (opencvDebugDisplay == OCVDD_ABS_DIFF) {
            image(opencv.getMemory2(), 0, 0);
            fill(255, 255, 0);
            text("abs diff", 10, 20);
        }
        
        // do binary thresholding on image
        float binaryThreshold = 0.2;
        opencv.threshold(opencv.Memory2, binaryThreshold, "BINARY");
        // if corresp. debug mode is on, display thresholed image
        if (opencvDebugDisplay == OCVDD_THRESHOLDED) {
            image(opencv.getMemory2(), 0, 0);
            fill(255, 255, 0);
            text("thresholded", 10, 20);
        }
        
        // detect blobs on thresholded image
        long minAreaIn = opencv.area()/64;
        long maxAreaIn = opencv.area();
        int maxBlobIn = 16;
        boolean findHolesIn = false;
        int maxVerticesIn = 4096;
        boolean debug = false;
        blobs = opencv.blobs(opencv.Memory2, minAreaIn, maxAreaIn, maxBlobIn, findHolesIn, maxVerticesIn, debug);
        // display blob debug information if needed
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
            // capture reference frame
            opencv.remember();
            // launch Bezier wall
            bezierWall.launch();
        }
    } else if (key == ENTER || key == RETURN) {
        bezierWall.reset();
    } else if (key == '0') {
        bezierWall.toggleFixedFirstLastPts();
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

