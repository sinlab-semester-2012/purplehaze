
class Halo {
    
    final float DEFAULT_RADIUS = 0.125*(width + height);
    final float RADIUS_INCREMENT = DEFAULT_RADIUS/10;
    
    PVector pos;
    float radius;
    float hue;

    Halo(PVector p) {
        pos = p.get();
        radius = DEFAULT_RADIUS;
        hue = random(0, 360);
    }
    
    // set position
    void setPos(PVector p) {
        pos = p.get();
    }
    
    // shoot projectile
    void shoot(PVector direction) {
        
    }
    
    // increase radius
    void increaseRadius() {
        radius = radius + RADIUS_INCREMENT;
    }
    
    // decrease radius
    void decreaseRadius() {
        radius = min(0, radius - RADIUS_INCREMENT);
    }
    
    // draw halo
    void draw() {
        colorMode(HSB, 360, 100, 100);
        noStroke();
        drawGradientDisk(pos.x, pos.y, radius);
    }
    
    // draw radial gradient in disk
    void drawGradientDisk(float x, float y, float radius) {
        int h = round(hue);
        
        for (int r = round(radius); r > 0; r--) {
            fill(h, 100, 100);
            ellipse(x, y, r, r);
            h = (h + 1) % 360;
        }
    }
}

