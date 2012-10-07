class DynBezierCurve {
    
    final int MIN_NBPOINTS = 2;
    final int MAX_NBPOINTS = 7;
    final float POINT_DISPLACEMENT_RANGE = 100;
    final float POINT_RADIUS = 200;
    
    int nbPoints;
    int nbCtrlPoints;
    PVector[] points;
    PVector[] ctrlPoints;
    float bgWidth;
    float bgHeight;

    DynBezierCurve(int nbP, float bgW, float bgH) {
        nbPoints = nbP;
        nbCtrlPoints = 2*nbPoints - 2;
        bgWidth = bgW;
        bgHeight = bgH;
        generate();
    }
    
    void generate() {
        points = new PVector[nbPoints];
        for (int i = 0; i < nbPoints; i++) {
            points[i] = new PVector();
        }
        ctrlPoints = new PVector[nbCtrlPoints];
        for (int i = 0; i < nbCtrlPoints; i++) {
            ctrlPoints[i] = new PVector();
        }
        
        genPts();
        genCtrlPts();
    }
    
    void genPts() {
        genFirstLastPts();
        if (nbPoints >= 3) {
            genMiddlePts();
        }
    }
    
    void genFirstLastPts() {
        // choose randomly first and last points on two sides of screen
        float r1 = random(0, 1);
        float r2 = random(0, 1);
        
        if (0 <= r1 && r1 < 0.25) {
            points[0].set(0, random(0, bgHeight), 0);
            if (0 <= r2 && r2 < 0.33) {
                points[nbPoints-1].set(random(0, bgWidth), bgHeight, 0);
            } else if (0.33 <= r2 && r2 < 0.66) {
                points[nbPoints-1].set(bgWidth, random(0, bgHeight), 0);
            } else if (0.66 <= r2 && r2 < 1.0) {
                points[nbPoints-1].set(random(0, bgWidth), 0, 0);
            }
        } else if (0.25 <= r1 && r1 < 0.5) {
            points[0].set(random(0, bgWidth), bgHeight, 0);
            if (0 <= r2 && r2 < 0.33) {
                points[nbPoints-1].set(bgWidth, random(0, bgHeight), 0);
            } else if (0.33 <= r2 && r2 < 0.66) {
                points[nbPoints-1].set(random(0, bgWidth), 0, 0);
            } else if (0.66 <= r2 && r2 < 1.0) {
                points[nbPoints-1].set(0, random(0, bgHeight), 0);
            }
        } else if (0.5 <= r1 && r1 < 0.75) {
            points[0].set(bgWidth, random(0, bgHeight), 0);
            if (0 <= r2 && r2 < 0.33) {
                points[nbPoints-1].set(random(0, bgWidth), 0, 0);
            } else if (0.33 <= r2 && r2 < 0.66) {
                points[nbPoints-1].set(0, random(0, bgHeight), 0);
            } else if (0.66 <= r2 && r2 < 1.0) {
                points[nbPoints-1].set(random(0, bgWidth), bgHeight, 0);
            }
        } else if (0.75 <= r1 && r1 < 1.0) {
            points[0].set(random(0, bgWidth), 0, 0);
            if (0 <= r2 && r2 < 0.33) {
                points[nbPoints-1].set(0, random(0, bgHeight), 0);
            } else if (0.33 <= r2 && r2 < 0.66) {
                points[nbPoints-1].set(random(0, bgWidth), bgHeight, 0);
            } else if (0.66 <= r2 && r2 < 1.0) {
                points[nbPoints-1].set(bgWidth, random(0, bgHeight), 0);
            }
        }
            
    }
    
    void genMiddlePts() {
        float xInterval = (points[nbPoints-1].x - points[0].x) / (nbPoints - 1);
        float yInterval = (points[nbPoints-1].y - points[0].y) / (nbPoints - 1);
        float xPosition = -1;
        float yPosition = -1;
        
        for (int i = 1; i < nbPoints - 1; i++) {
            while (xPosition < 0 || bgWidth < xPosition) {
                xPosition = points[0].x + i*xInterval + random(0, POINT_DISPLACEMENT_RANGE);
            }
            while (yPosition < 0 || bgHeight < yPosition) {
                yPosition = points[0].y + i*yInterval + random(0, POINT_DISPLACEMENT_RANGE);
            }
            points[i].set(xPosition, yPosition, 0);
            
            xPosition = -1;
            yPosition = -1;
        }
    }
    
    void genCtrlPts() {
        genFirstLastCtrlPts();
        if (nbPoints > MIN_NBPOINTS) {
            genMiddleCtrlPts();
        }
    }
    
    void genFirstLastCtrlPts() {
        ctrlPoints[0] = genRandCtrlPtInRadius(points[0]);
        ctrlPoints[nbCtrlPoints - 1] = genRandCtrlPtInRadius(points[nbPoints - 1]);
    }
    
    void genMiddleCtrlPts() {
        ctrlPoints[1] = genRandCtrlPtInRadius(points[1]);
        for (int j = 2; j < nbCtrlPoints - 1; j++) {
            
        }
    }
    
    PVector genRandCtrlPtInRadius(PVector pt) {
        PVector ctrlPt;
        float r = random(0, POINT_RADIUS);
        float theta = random(0, TWO_PI);
        ctrlPt = new PVector(pt.x + r*cos(theta), pt.y + r*sin(theta));
        return ctrlPt;
    }
    
    void move() {
        
    }
    
    void draw() {
        noStroke();
        for (int i = 0; i < nbPoints; i++) {
            fill(0, 255, 0);
            ellipse(points[i].x, points[i].y, 20, 20);
        }
        for (int j = 0; j < nbCtrlPoints; j++) {
            fill(255, 0, 0);
            ellipse(ctrlPoints[j].x, ctrlPoints[j].y, 10, 10);
        }
        
        stroke(255);
        strokeWeight(5);
        noFill();
        beginShape();
        vertex(points[0].x, points[0].y);
        int j = 1;
        for (int i = 1; i < nbPoints; i++) {
            bezierVertex(ctrlPoints[j - 1].x, ctrlPoints[j - 1].y, 
                ctrlPoints[j].x, ctrlPoints[j].y, 
                points[i].x, points[i].y);
            j = j + 2;
        }
        endShape();
    }

    void decreaseNbPoints() {
        if (nbPoints > MIN_NBPOINTS) {
            nbPoints--;
            nbCtrlPoints = 2*nbPoints - 2;
            generate();
        }
    }
    
    void increaseNbPoints() {
        if (nbPoints < MAX_NBPOINTS) {
            nbPoints++;
            nbCtrlPoints = 2*nbPoints - 2;
            generate();
        }
    }
}

