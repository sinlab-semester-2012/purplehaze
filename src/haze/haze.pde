DynBezierCurve dynBezierCurve;

void setup() {
    size(800, 600);
    if (frame != null) {
        frame.setResizable(true);
    }
    background(0);
    
    dynBezierCurve = new DynBezierCurve(2);
}

void draw() {
    background(0);
    dynBezierCurve.move();
    dynBezierCurve.draw();
}

void keyPressed() {
    if (key == ' ') {
        dynBezierCurve.reset();
    } else if (key == '-') {
        dynBezierCurve.decreaseNbPoints();
    } else if (key == '+') {
        dynBezierCurve.increaseNbPoints();
    } else if (key == '*') {
        dynBezierCurve.toggleFixedFirstLastPts();
    }
}
