DynBezierCurve dynBezierCurve;

void setup() {
    size(800, 600);
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
        dynBezierCurve.generate();
    } else if (key == '-') {
        dynBezierCurve.decreaseNbPoints();
    } else if (key == '+') {
        dynBezierCurve.increaseNbPoints();
    }
}
