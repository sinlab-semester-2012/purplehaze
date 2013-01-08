import codeanticode.gsvideo.*;
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

FightingHalos fightingHalos;

int opencvDebugDisplay;
static final int OCVDD_NONE = 0;
static final int OCVDD_BLURRED_CAPTURED = 1;
static final int OCVDD_REFRERENCE = 2;
static final int OCVDD_ABS_DIFF = 3;
static final int OCVDD_THRESHOLDED = 4;
static final int OCVDDSIZE = 5;
boolean blobDebugDisplay;

void setup() {
    size(widthScreen, heightScreen);
    background(0);
    smooth();
    frameRate(fps);
    
    cam = new GSCapture(this, widthCapture, heightCapture, fpsCapture);
    cam.start();
    
    opencv = new OpenCV(this);
    opencv.allocate(widthScreen, heightScreen);
    
    opencvDebugDisplay = OCVDD_NONE;
    blobDebugDisplay = false;
    
    fightingHalos = new FightingHalos();
}

void draw() {
    background(0);
    
    if (cam.available()) {
        cam.read();
        
        PImage camImgResized = cam.get();
        camImgResized.resize(widthScreen, heightScreen);
        opencv.copy(camImgResized);
        
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
    
    fightingHalos.draw();
    fightingHalos.interact(blobs);
}

void toggleOpencvDebugDisplay() {
    opencvDebugDisplay = (opencvDebugDisplay + 1) % OCVDDSIZE;
}

void toggleBlobDebugDisplay() {
    blobDebugDisplay = !blobDebugDisplay;
}

void keyPressed() {
    if (key == ' ') {
        if (fightingHalos.isInInitState()) {
            opencv.remember();
            fightingHalos.launch();
        }
    } else if (key == '/') {
        toggleOpencvDebugDisplay();
    } else if (key == '*') {
        toggleBlobDebugDisplay();
    }
    
    // DEBUG
    if (key == 's') {
        fightingHalos.debugHaloMove(1, new PVector(0, 25, 0));
    } else if (key == 'w') {
        fightingHalos.debugHaloMove(1, new PVector(0, -25, 0));
    } else if (key == 'a') {
        fightingHalos.debugHaloMove(1, new PVector(-25, 0, 0));
    } else if (key == 'd') {
        fightingHalos.debugHaloMove(1, new PVector(25, 0, 0));
    } else if (key == 'e') {
        fightingHalos.debugHaloShoot(1);
    }
}

// DEBUG
void mouseReleased() {
    fightingHalos.debugHaloShoot(0);
}

