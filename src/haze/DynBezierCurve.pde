
class DynBezierCurve {
    
    final int MIN_NB_POINTS = 2;
    final int MAX_NB_POINTS = 7;
    
    final float POINT_LOCATION_RANGE = 0.1*(width + height);
    final float CTRL_POINT_LOCATION_RANGE = 0.2*(width + height);
    
    final float POINT_ELLIPSE_MOVE_MIN_RADIUS = 0;
    final float POINT_ELLIPSE_MOVE_MAX_RADIUS = 0.05*(width + height);
    final float POINT_ANGLE_INCREMENT = 0.05;
    
    final float CTRL_POINT_ELLIPSE_MOVE_MIN_RADIUS = 0;
    final float CTRL_POINT_ELLIPSE_MOVE_MAX_RADIUS = 0.075*(width + height);
    final float CTRL_POINT_ANGLE_INCREMENT = 0.05;
    
    final int NB_MOVE_PARAMS = 5;
    
    int nbPoints;
    int nbCtrlPoints;
    PVector[] points;
    float[][] pointsMoveParams;
    PVector[] ctrlPoints;
    float[][] ctrlPointsMoveParams;


    DynBezierCurve(int nbP) {
        nbPoints = nbP;
        nbCtrlPoints = 2*nbPoints - 2;
        generate();
    }
    
    // create Bezier curve
    void generate() {
        points = new PVector[nbPoints];
        pointsMoveParams = new float[nbPoints][NB_MOVE_PARAMS];
        for (int i = 0; i < nbPoints; i++) {
            points[i] = new PVector();
        }
        ctrlPoints = new PVector[nbCtrlPoints];
        ctrlPointsMoveParams = new float[nbCtrlPoints][NB_MOVE_PARAMS];
        for (int j = 0; j < nbCtrlPoints; j++) {
            ctrlPoints[j] = new PVector();
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
            ctrlPoints[j + 1] = genRandCtrlPtOnLine(ctrlPoints[j], points[i]);
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
    
    // get random control point on line given by control point and position point
    PVector genRandCtrlPtOnLine(PVector ctrlPt, PVector pt) {
        PVector newCtrlPt;
        PVector dir = PVector.sub(pt, ctrlPt);
        dir.div(dir.mag());
        PVector dirMult = PVector.mult(dir, random(0, CTRL_POINT_LOCATION_RANGE));
        newCtrlPt = PVector.add(pt, dirMult);
        return newCtrlPt;
    }
    
    // generate move parameters
    void genMoveParams() {
        genPtsMoveParams();
        genCtrlPtsMoveParams();
    }
    
    // generate move parameters for position points
    void genPtsMoveParams() {
        float a, b, xCenter, yCenter, theta;
        for (int i = 0; i < nbPoints; i++) {
            a = random(POINT_ELLIPSE_MOVE_MIN_RADIUS, POINT_ELLIPSE_MOVE_MAX_RADIUS);
            b = random(POINT_ELLIPSE_MOVE_MIN_RADIUS, POINT_ELLIPSE_MOVE_MAX_RADIUS);
            theta = random(0, TWO_PI);
            xCenter = points[i].x - a*cos(theta);
            yCenter = points[i].y - b*cos(theta);
            pointsMoveParams[i][0] = a;
            pointsMoveParams[i][1] = b;
            pointsMoveParams[i][2] = xCenter;
            pointsMoveParams[i][3] = yCenter;
            pointsMoveParams[i][4] = theta;
        }
    }
    
    // generate move parameters for control points
    void genCtrlPtsMoveParams() {
        float a, b, xCenter, yCenter, theta;
        for (int j = 0; j < nbCtrlPoints; j++) {
            a = random(CTRL_POINT_ELLIPSE_MOVE_MIN_RADIUS, CTRL_POINT_ELLIPSE_MOVE_MAX_RADIUS);
            b = random(CTRL_POINT_ELLIPSE_MOVE_MIN_RADIUS, CTRL_POINT_ELLIPSE_MOVE_MAX_RADIUS);
            theta = random(0, TWO_PI);
            xCenter = ctrlPoints[j].x - a*cos(theta);
            yCenter = ctrlPoints[j].y - b*cos(theta);
            ctrlPointsMoveParams[j][0] = a;
            ctrlPointsMoveParams[j][1] = b;
            ctrlPointsMoveParams[j][2] = xCenter;
            ctrlPointsMoveParams[j][3] = yCenter;
            ctrlPointsMoveParams[j][4] = theta;
        }        
    }
    
    // make Bezier curve vary
    void move() {
        movePts();
        moveCtrlPts();
    }
    
    // make position points vary (move on an ellipse)
    void movePts() {
        for (int i = 1; i < nbPoints - 1; i++) {
            movePt(i);
        }
    }
    
    // move single position point
    void movePt(int i) {
        float a, b, xCenter, yCenter, theta;
        a = pointsMoveParams[i][0];
        b = pointsMoveParams[i][1];
        xCenter = pointsMoveParams[i][2];
        yCenter = pointsMoveParams[i][3];
        theta = pointsMoveParams[i][4];
        theta = (theta + POINT_ANGLE_INCREMENT) % TWO_PI;
        points[i].set(xCenter + a*cos(theta), yCenter + b*sin(theta), 0);
        pointsMoveParams[i][4] = theta;
    }
    
    // make control points vary (move on an ellipse)
    void moveCtrlPts() {
        moveCtrlPt(0);
        moveCtrlPt(nbCtrlPoints - 1);
        int j = 1;
        for (int i = 1; i < nbPoints - 1; i++) {
            moveCtrlPt(j);
            moveCtrlPt(j + 1);
            // project second control point on line for continous curve
            moveCtrlPtOnLine(i, j, j + 1);
            // if both control points are on same side of curve, flip one of them
            PVector ptToCtrlPt1 = PVector.sub(ctrlPoints[j], points[i]);
            PVector ptToCtrlPt2 = PVector.sub(ctrlPoints[j + 1], points[i]);
            if (PVector.dot(ptToCtrlPt1, ptToCtrlPt2) >= 0) {
                ptToCtrlPt2.set(-ptToCtrlPt2.x, -ptToCtrlPt2.y, 0);
                ctrlPoints[j + 1] = PVector.add(points[i], ptToCtrlPt2);
            }
            j = j + 2;
        }
    }
    
    // move single control point
    void moveCtrlPt(int j) {
        float a, b, xCenter, yCenter, theta;
        a = ctrlPointsMoveParams[j][0];
        b = ctrlPointsMoveParams[j][1];
        xCenter = ctrlPointsMoveParams[j][2];
        yCenter = ctrlPointsMoveParams[j][3];
        theta = ctrlPointsMoveParams[j][4];
        theta = (theta + CTRL_POINT_ANGLE_INCREMENT) % TWO_PI;
        ctrlPoints[j].set(xCenter + a*cos(theta), yCenter + b*sin(theta), 0);
        ctrlPointsMoveParams[j][4] = theta;
    }
    
    // project control point on given line
    void moveCtrlPtOnLine(int i, int j1, int j2) {
        PVector dir = PVector.sub(points[i], ctrlPoints[j1]);
        dir.div(dir.mag());
        PVector ctrlPt1ToCtrlPt2 = PVector.sub(ctrlPoints[j2], ctrlPoints[j1]);
        PVector mov = PVector.mult(dir, PVector.dot(dir, ctrlPt1ToCtrlPt2));
        ctrlPoints[j2] = PVector.add(ctrlPoints[j1], mov);
    }
    
    // draw Bezier curve on screen
    void draw() {
        // draw position points and control points
        noStroke();
        fill(0, 255, 0);
        ellipse(points[0].x, points[0].y, 20, 20);
        ellipse(points[nbPoints - 1].x, points[nbPoints - 1].y, 20, 20);
        fill(255, 0, 0);
        ellipse(ctrlPoints[0].x, ctrlPoints[0].y, 10, 10);
        ellipse(ctrlPoints[nbCtrlPoints - 1].x, ctrlPoints[nbCtrlPoints - 1].y, 10, 10);
        strokeWeight(1);
        stroke(255, 0, 0);
        line(ctrlPoints[0].x, ctrlPoints[0].y, points[0].x, points[0].y);
        line(ctrlPoints[nbCtrlPoints - 1].x, ctrlPoints[nbCtrlPoints - 1].y, points[nbPoints - 1].x, points[nbPoints - 1].y);
        noStroke();
        int n = 1;
        for (int m = 1; m < nbPoints - 1; m++) {
            fill(0, 255, 0);
            ellipse(points[m].x, points[m].y, 20, 20);
            fill(255, 0, 0);
            ellipse(ctrlPoints[n].x, ctrlPoints[n].y, 10, 10);
            ellipse(ctrlPoints[n + 1].x, ctrlPoints[n + 1].y, 10, 10);
            strokeWeight(1);
            stroke(255, 0, 0);
            line(ctrlPoints[n].x, ctrlPoints[n].y, points[m].x, points[m].y);
            line(ctrlPoints[n + 1].x, ctrlPoints[n + 1].y, points[m].x, points[m].y);
            noStroke();
            n = n + 2;
        }
        
        // draw curve
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

