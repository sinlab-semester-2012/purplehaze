DynBezierCurve dynBezierCurve;

void setup() {
    size(640, 480);
    background(0);
    
    dynBezierCurve = new DynBezierCurve(2, width, height);
}

void draw() {
    background(0);
    dynBezierCurve.move();
    dynBezierCurve.draw();
}

void keyPressed() {
    if (key == ' ') {
        dynBezierCurve.generate();
    } else if (key == '-') {
        dynBezierCurve.decreaseNbPoints();
    } else if (key == '+') {
        dynBezierCurve.increaseNbPoints();
    }
}
