import codeanticode.gsvideo.*;
import monclubelec.javacvPro.*;


GSCapture cam;
OpenCV opencv;

Blob[] blobs;
DynBezierCurve dynBezierCurve;

void setup() {
    size(640, 480);
    background(0);
    
    dynBezierCurve = new DynBezierCurve(2);
}

void draw() {
    background(0);
    dynBezierCurve.draw();
    dynBezierCurve.move();
    dynBezierCurve.interact(blobs);
}

void keyPressed() {
    if (key == ENTER || key == RETURN) {
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
