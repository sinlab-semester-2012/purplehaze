
class Halo {
    
    final float DEFAULT_RADIUS = 0.125*(width + height);
    final float MIN_RADIUS = 0.2*DEFAULT_RADIUS;
    final float RADIUS_INCREMENT = 0.1*DEFAULT_RADIUS;
    
    final float PROJECTILE_RADIUS = 0.33*DEFAULT_RADIUS;
    final float PROJECTILE_SPEED = 50.0;
    
    final float HIT_DURATION_MS = 4000;
    final float HIT_FLICKER_DURATION_MS = 1000;
    
    PVector pos;
    float haloRadius;
    float hue;
    
    boolean isShooting;
    PVector projectileDir;
    PVector projectilePos;
    boolean recentlyHit;
    
    float prevMillisHit;

    Halo(PVector p) {
        pos = p.get();
        haloRadius = DEFAULT_RADIUS;
        hue = random(0, 360);
        
        isShooting = false;
        projectileDir = new PVector();
        projectilePos = new PVector();
        recentlyHit = false;
        prevMillisHit = millis();
    }
    
    // get position
    PVector getPos() {
        return new PVector(pos.x, pos.y, 0);
    }
    
    // set position
    void setPos(PVector p) {
        pos.set(p.x, p.y, 0);
    }
    
    // increase haloRadius
    void increaseRadius() {
        haloRadius = haloRadius + RADIUS_INCREMENT;
    }
    
    // decrease haloRadius
    void decreaseRadius() {
        haloRadius = max(MIN_RADIUS, haloRadius - RADIUS_INCREMENT);
    }
    
    // shoot projectile
    void shoot(PVector direction) {
        if (!isShooting) {
            decreaseRadius();
            projectileDir.set(direction.x, direction.y, 0);
            projectilePos.set(pos.x, pos.y, 0);
            isShooting = true;
        }
    }
    
    // move projectile
    void moveProjectile() {
        PVector movement = PVector.mult(projectileDir, PROJECTILE_SPEED);
        projectilePos.add(movement);
    }
    
    // check whether projectile is off screen and destroy it if so
    void checkProjectileExistence() {
        PVector p = new PVector(projectilePos.x, projectilePos.y, 0);
        float rd = PROJECTILE_RADIUS;
        if (p.x + rd < 0 || p.x - rd >= width || p.y + rd < 0 || p.y - rd >= height) {
            destroyProjectile();
        }
    }
    
    // destroy projectile
    void destroyProjectile() {
        isShooting = false;
        projectileDir.set(0, 0, 0);
        projectilePos.set(0, 0, 0);
    }
    
    // check if Halo is hit by another projectile
    boolean isHitBy(PVector otherProjectilePos) {
        boolean hit = false;
        
        float distance = PVector.sub(pos, otherProjectilePos).mag();
        if (!recentlyHit && distance < haloRadius + PROJECTILE_RADIUS) {
            recentlyHit = true;
            hit = true;
        }
        
        return hit;
    }
    
    void checkRecentlyHit() {
        if (recentlyHit && millis() - prevMillisHit > HIT_DURATION_MS) {
            println("BLABLO");
            recentlyHit = false;
            prevMillisHit = millis();
        }
    }
    
    // check whether halo is shooting
    boolean isShooting() {
        return isShooting;
    }
    
    // get projectile position
    PVector getProjectilePos() {
        return new PVector(projectilePos.x, projectilePos.y, 0);
    }
    
    // draw halo
    void draw() {
        colorMode(HSB, 360, 100, 100);
        noStroke();
        boolean recentlyHitFlicker = recentlyHit && millis() % HIT_FLICKER_DURATION_MS < HIT_FLICKER_DURATION_MS/2;
        if (!recentlyHit || recentlyHitFlicker) {
        drawGradientDisk(pos.x, pos.y, haloRadius);
        }
        if (isShooting) {
            drawProjectile();
        }
    }
    
    // draw radial gradient in disk
    void drawGradientDisk(float x, float y, float haloRadius) {
        int h = round(hue);
        
        for (int r = round(haloRadius); r > 0; r--) {
            fill(h, 100, 100);
            ellipse(x, y, r, r);
            h = (h + 1) % 360;
        }
    }
    
    void drawProjectile() {
        int h = round(hue);
        
        for (int r = round(PROJECTILE_RADIUS); r > 0; r--) {
            fill(h, 100, 100);
            ellipse(projectilePos.x, projectilePos.y, r, r);
            h = (h + 1) % 360;
        }
    }
}

