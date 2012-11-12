import codeanticode.gsvideo.*;
import monclubelec.javacvPro.*;


GSCapture cam;
OpenCV opencv;

int widthCapture = 640;
int heightCapture = 480;
int fpsCapture = 30;

Blob[] blobs;
Maze maze;

void setup() {
    size(widthCapture, heightCapture);
    background(0);
    smooth();
    
    frameRate(fpsCapture);
    cam = new GSCapture(this, widthCapture, heightCapture, fpsCapture);
    cam.start();
    opencv = new OpenCV(this);
    opencv.allocate(widthCapture, heightCapture);
    
    maze = new Maze(8, 6);
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
    
    maze.draw();
    if (blobs != null && blobs.length > 0) {
        maze.interact(blobs[0]);
    }
}

void keyPressed() {
    if (key == ' ') {
        
    } else if (key == ENTER || key == RETURN) {
        
    }
}

