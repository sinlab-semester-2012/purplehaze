class DynEllipse {
    
    float MIN_WIDTH = 0.05*(width + height);
    float MAX_WIDTH = 0.1*(width + height);
    float MIN_HEIGHT = 0.05*(width + height);
    float MAX_HEIGHT = 0.1*(width + height);
    
    float x;
    float y;
    float w;
    float h;

    float r;
    float g;
    float b;

    DynEllipse() {
        generateRandPosDynEllipse();
    }
    
    void generateDynEllipse() {
        setSize(random(MIN_WIDTH, MAX_WIDTH), random(MIN_HEIGHT, MAX_HEIGHT));
        setColor(random(0, 255), random(0, 255), random(0, 255));
    }
    
    void generateRandPosDynEllipse() {
        x = random(0, width);
        y = random(0, height);
        generateDynEllipse();
    }
    
    void drawDynEllipse() {
        noStroke();
        fill(r, g, b);
        ellipseMode(CENTER);
        ellipse(x, y, w, h);
    }
    
    void drawDynEllipse(float posX, float posY) {
        setPos(posX, posY);
        drawDynEllipse();
    }

    void setPos(float posX, float posY) {
        x = posX;
        y = posY;
    }

    void setSize(float sizeW, float sizeH) {
        w = sizeW;
        h = sizeH;
    }
    
    void setColor(float red, float green, float blue) {
        r = red;
        b = blue;
        g = green;
    }
}

