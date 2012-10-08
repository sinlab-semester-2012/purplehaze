
class DynBezierCurve {
    
    final int MIN_NB_POINTS = 2;
    final int MAX_NB_POINTS = 7;
    
    final float POINT_LOCATION_RANGE = 0.1*(width + height);
    final float CTRL_POINT_LOCATION_RANGE = 0.25*(width + height);
    
    final float POINT_ELLIPSE_MOVE_MIN_RADIUS = 0;
    final float POINT_ELLIPSE_MOVE_MAX_RADIUS = 0.05*(width + height);
    final float POINT_ANGLE_INCREMENT = 0.05;
    
    final float CTRL_POINT_ELLIPSE_MOVE_MIN_RADIUS = 0;
    final float CTRL_POINT_ELLIPSE_MOVE_MAX_RADIUS = 0.075*(width + height);
    final float CTRL_POINT_ANGLE_INCREMENT = 0.05;
    
    
    int nbPoints;
    int nbCtrlPoints;
    PVector[] points;
    PVector[] pointsMoveParams;
    PVector[] ctrlPoints;
    PVector[] ctrlPointsMoveParams;


    DynBezierCurve(int nbP) {
        nbPoints = nbP;
        nbCtrlPoints = 2*nbPoints - 2;
        generate();
    }
    
    // create Bezier curve
    void generate() {
        points = new PVector[nbPoints];
        pointsMoveParams = new PVector[nbPoints];
        for (int i = 0; i < nbPoints; i++) {
            points[i] = new PVector();
            pointsMoveParams[i] = new PVector();
        }
        ctrlPoints = new PVector[nbCtrlPoints];
        ctrlPointsMoveParams = new PVector[nbCtrlPoints];
        for (int j = 0; j < nbCtrlPoints; j++) {
            ctrlPoints[j] = new PVector();
            ctrlPointsMoveParams[j] = new PVector();
        }
        
        genPts();
        genCtrlPts();
        genMoveParams();
    }
    
    // generate points (positions)
    void genPts() {
        genFirstLastPts();
        if (nbPoints >= 3) {
            genMiddlePts();
        }
    }
    
    // randomly pick first and last points on two sides of screen
    void genFirstLastPts() {
        float r1 = random(0, 1);
        float r2 = random(0, 1);
        
        if (0 <= r1 && r1 < 0.25) {
            points[0].set(0, random(0, height), 0);
            if (0 <= r2 && r2 < 0.33) {
                points[nbPoints-1].set(random(0, width), height, 0);
            } else if (0.33 <= r2 && r2 < 0.66) {
                points[nbPoints-1].set(width, random(0, height), 0);
            } else if (0.66 <= r2 && r2 < 1.0) {
                points[nbPoints-1].set(random(0, width), 0, 0);
            }
        } else if (0.25 <= r1 && r1 < 0.5) {
            points[0].set(random(0, width), height, 0);
            if (0 <= r2 && r2 < 0.33) {
                points[nbPoints-1].set(width, random(0, height), 0);
            } else if (0.33 <= r2 && r2 < 0.66) {
                points[nbPoints-1].set(random(0, width), 0, 0);
            } else if (0.66 <= r2 && r2 < 1.0) {
                points[nbPoints-1].set(0, random(0, height), 0);
            }
        } else if (0.5 <= r1 && r1 < 0.75) {
            points[0].set(width, random(0, height), 0);
            if (0 <= r2 && r2 < 0.33) {
                points[nbPoints-1].set(random(0, width), 0, 0);
            } else if (0.33 <= r2 && r2 < 0.66) {
                points[nbPoints-1].set(0, random(0, height), 0);
            } else if (0.66 <= r2 && r2 < 1.0) {
                points[nbPoints-1].set(random(0, width), height, 0);
            }
        } else if (0.75 <= r1 && r1 < 1.0) {
            points[0].set(random(0, width), 0, 0);
            if (0 <= r2 && r2 < 0.33) {
                points[nbPoints-1].set(0, random(0, height), 0);
            } else if (0.33 <= r2 && r2 < 0.66) {
                points[nbPoints-1].set(random(0, width), height, 0);
            } else if (0.66 <= r2 && r2 < 1.0) {
                points[nbPoints-1].set(width, random(0, height), 0);
            }
        }
            
    }
    
    // generate middle points (distribute evenly and add some randomness)
    void genMiddlePts() {
        float xInterval = (points[nbPoints-1].x - points[0].x) / (nbPoints - 1);
        float yInterval = (points[nbPoints-1].y - points[0].y) / (nbPoints - 1);
        float xPosition = -1;
        float yPosition = -1;
        
        for (int i = 1; i < nbPoints - 1; i++) {
            while (xPosition < 0 || width < xPosition) {
                xPosition = points[0].x + i*xInterval + random(0, POINT_LOCATION_RANGE);
            }
            while (yPosition < 0 || height < yPosition) {
                yPosition = points[0].y + i*yInterval + random(0, POINT_LOCATION_RANGE);
            }
            points[i].set(xPosition, yPosition, 0);
            
            xPosition = -1;
            yPosition = -1;
        }
    }
    
    // generate control points (positions)
    void genCtrlPts() {
        genFirstLastCtrlPts();
        if (nbPoints > MIN_NB_POINTS) {
            genMiddleCtrlPts();
        }
    }
    
    // randomly pick first and last control points in defined radius
    void genFirstLastCtrlPts() {
        PVector firstCtrlPt = new PVector(-1, -1, 0);
        PVector lastCtrlPt = new PVector(-1, -1, 0);
        while (firstCtrlPt.x < 0 || firstCtrlPt.x > width || firstCtrlPt.y < 0 || firstCtrlPt.y > height) {
            firstCtrlPt = genRandCtrlPtInRadius(points[0]);
        }
        while (lastCtrlPt.x < 0 || lastCtrlPt.x > width || lastCtrlPt.y < 0 || lastCtrlPt.y > height) {
            lastCtrlPt = genRandCtrlPtInRadius(points[nbPoints - 1]);
        }
        ctrlPoints[0] = firstCtrlPt;
        ctrlPoints[nbCtrlPoints - 1] = lastCtrlPt;
    }
    
    // generate middle control points
    // (continuity assured by aligning every other control point with
    // previous control point and its corresponding position point)
    void genMiddleCtrlPts() {
        PVector direction = new PVector();
        int j = 1;
        for (int i = 1; i < nbPoints - 1; i++) {
            ctrlPoints[j] = genRandCtrlPtInRadius(points[i]);
            direction = PVector.sub(points[i], ctrlPoints[j]);
            direction.div(direction.mag());
            ctrlPoints[j+1] = genRandCtrlPtOnLine(points[i], direction);
            j = j + 2;
        }
    }
    
    // get random control point in radius of given point
    PVector genRandCtrlPtInRadius(PVector pt) {
        PVector ctrlPt;
        float r = random(0, CTRL_POINT_LOCATION_RANGE);
        float theta = random(0, TWO_PI);
        ctrlPt = new PVector(pt.x + r*cos(theta), pt.y + r*sin(theta));
        return ctrlPt;
    }
    
    // get random control point on line given by point and direction
    PVector genRandCtrlPtOnLine(PVector pt, PVector dir) {
        PVector ctrlPt;
        PVector dirMult = PVector.mult(dir, random(0, CTRL_POINT_LOCATION_RANGE));
        ctrlPt = PVector.add(pt, dirMult);
        return ctrlPt;
    }
    
    // generate move parameters
    void genMoveParams() {
        genPtsMoveParams();
        genCtrlPtsMoveParams();
    }
    
    // generate move parameters for position points
    void genPtsMoveParams() {
        float a, b, theta;
        for (int i = 0; i < nbPoints; i++) {
            a = random(POINT_ELLIPSE_MOVE_MIN_RADIUS, POINT_ELLIPSE_MOVE_MAX_RADIUS);
            b = random(POINT_ELLIPSE_MOVE_MIN_RADIUS, POINT_ELLIPSE_MOVE_MAX_RADIUS);
            theta = random(0, TWO_PI);
            pointsMoveParams[i].set(a, b, theta);
        }
    }
    
    // generate move parameters for control points
    void genCtrlPtsMoveParams() {
        float a, b, theta;
        for (int j = 0; j < nbCtrlPoints; j++) {
            a = random(CTRL_POINT_ELLIPSE_MOVE_MIN_RADIUS, CTRL_POINT_ELLIPSE_MOVE_MAX_RADIUS);
            b = random(CTRL_POINT_ELLIPSE_MOVE_MIN_RADIUS, CTRL_POINT_ELLIPSE_MOVE_MAX_RADIUS);
            theta = random(0, TWO_PI);
            ctrlPointsMoveParams[j].set(a, b, theta);
        }        
    }
    
    // make Bezier curve vary
    void move() {
        movePts();
        moveCtrlPts();
    }
    
    // make position points vary (move on an ellipse)
    void movePts() {
        float a, b, theta;
        PVector posToCenter = new PVector();
        PVector centerToPos = new PVector(); 
        for (int i = 1; i < nbPoints - 1; i++) {
            a = pointsMoveParams[i].x;
            b = pointsMoveParams[i].y;
            theta = pointsMoveParams[i].z;
            posToCenter.set(a*cos(theta), b*sin(theta), 0);
            points[i].sub(posToCenter);
            theta = (theta + POINT_ANGLE_INCREMENT) % TWO_PI;
            centerToPos.set(a*cos(theta), b*sin(theta), 0);
            points[i].add(centerToPos);
            pointsMoveParams[i].set(a, b, theta);
        }
    }
    
    // make control points vary (move on an ellipse)
    void moveCtrlPts() {
        float a, b, theta;
        PVector posToCenter = new PVector();
        PVector centerToPos = new PVector(); 
        for (int j = 0; j < nbCtrlPoints; j++) {
            a = ctrlPointsMoveParams[j].x;
            b = ctrlPointsMoveParams[j].y;
            theta = ctrlPointsMoveParams[j].z;
            posToCenter.set(a*cos(theta), b*sin(theta), 0);
            ctrlPoints[j].sub(posToCenter);
            theta = (theta + POINT_ANGLE_INCREMENT) % TWO_PI;
            centerToPos.set(a*cos(theta), b*sin(theta), 0);
            ctrlPoints[j].add(centerToPos);
            ctrlPointsMoveParams[j].set(a, b, theta);
        }
    }
    
    // draw Bezier curve on screen
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
        strokeWeight(10);
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

    // decrease number of position points
    void decreaseNbPoints() {
        if (nbPoints > MIN_NB_POINTS) {
            nbPoints--;
            nbCtrlPoints = 2*nbPoints - 2;
            generate();
        }
    }
    
    // increase number of position points
    void increaseNbPoints() {
        if (nbPoints < MAX_NB_POINTS) {
            nbPoints++;
            nbCtrlPoints = 2*nbPoints - 2;
            generate();
        }
    }
}

