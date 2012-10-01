class DynEllipse {
    
    float MIN_WIDTH = 150;
    float MAX_WIDTH = 250;
    float MIN_HEIGHT = 150;
    float MAX_HEIGHT = 250;
    
    float x;
    float y;
    float w;
    float h;

    float r;
    float g;
    float b;

    DynEllipse() {
        x = 0;
        y = 0;
        w = 0;
        h = 0;
        r = 0;
        g = 0;
        b = 0;
    }
    
    void generateDynEllipse() {
        setSize(random(MIN_WIDTH, MAX_WIDTH), random(MIN_HEIGHT, MAX_HEIGHT));
        setColor(random(0, 255), random(0, 255), random(0, 255));
    }
    
    void drawDynEllipse() {
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

