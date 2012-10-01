DynEllipse dynEllipse;

void setup() {
    size(640, 480);
    background(0);
    
    dynEllipse = new DynEllipse();
}

void draw() {
    background(0);
    drawMouseDynEli();
}

void drawMouseDynEli() {
    float offset = 5;
    if (abs(mouseX - pmouseX) > offset || abs(mouseY - pmouseY) > offset) {
        dynEllipse.generateDynEllipse();
    }
    dynEllipse.drawDynEllipse(mouseX, mouseY);
}
