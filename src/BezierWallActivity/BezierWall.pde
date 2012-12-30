
class BezierWall {
    
    final int MIN_NB_POINTS = 2;
    final int MAX_NB_POINTS = 7;
    
    final float POINT_LOCATION_RANGE = 0.1*(width + height);
    final float CTRL_POINT_LOCATION_RANGE = 0.2*(width + height);
    
    final int NB_MOTION_PARAMS = 7;
    final float POINT_MOTION_ELLIPSE_MIN_RADIUS = 0;
    final float POINT_MOTION_ELLIPSE_MAX_RADIUS = 0.025*(width + height);
    final float POINT_ANGLE_INCREMENT = 0.1;
    final float CTRL_POINT_MOTION_ELLIPSE_MIN_RADIUS = 0;
    final float CTRL_POINT_MOTION_ELLIPSE_MAX_RADIUS = 0.075*(width + height);
    final float CTRL_POINT_ANGLE_INCREMENT = 0.05;
    
    final float NEAREST_MOTION_ELLIPSE_RADIUS = 0.1*(width + height);
    
    final color CURVE_COLOR = color(255);
    final float CURVE_STROKE_WEIGHT = 0.01*(width + height);
    
    int nbPoints;
    int nbCtrlPoints;
    PVector[] points;
    float[][] pointsMotionParams;
    PVector[] ctrlPoints;
    float[][] ctrlPointsMotionParams;
    
    int state;
    static final int S_INIT = 0;
    static final int S_RUNNING = 1;
    static final int SSIZE = 2;
    
    boolean debugDisplay;

    BezierWall(int nbP) {
        nbPoints = max(MIN_NB_POINTS, min(nbP, MAX_NB_POINTS));
        nbCtrlPoints = 2*nbPoints - 2;
        
        boolean fixedFirstLastPts = false;
        initialize(fixedFirstLastPts);
        generate(fixedFirstLastPts);
        
        state = S_INIT;
        
        debugDisplay = false;
    }
    
    // initialize data
    void initialize(boolean fixedFirstLastPts) {
        PVector tmpFirst = new PVector();
        PVector tmpLast = new PVector();
        if (points != null && fixedFirstLastPts) {
            tmpFirst = points[0];
            tmpLast = points[points.length - 1];
        }
        
        points = new PVector[nbPoints];
        pointsMotionParams = new float[nbPoints][NB_MOTION_PARAMS];
        for (int i = 0; i < nbPoints; i++) {
            points[i] = new PVector();
        }
        if (fixedFirstLastPts) {
            points[0] = tmpFirst;
            points[points.length - 1] = tmpLast;
        }
        
        ctrlPoints = new PVector[nbCtrlPoints];
        ctrlPointsMotionParams = new float[nbCtrlPoints][NB_MOTION_PARAMS];
        for (int j = 0; j < nbCtrlPoints; j++) {
            ctrlPoints[j] = new PVector();
        }
    }
    
    // create Bezier curve
    void generate(boolean fixedFirstLastPts) {
        genPts(fixedFirstLastPts);
        genCtrlPts();
        genMotionParams();
    }
    
    // generate points (positions)
    void genPts(boolean fixedFirstLastPts) {
        if (!fixedFirstLastPts) {
            genFirstLastPts();
        }
        if (nbPoints > MIN_NB_POINTS) {
            genMiddlePts();
        }
    }
    
    // randomly pick first and last points on two opposite sides of screen
    void genFirstLastPts() {
        float r = random(0, 1);
        
        if (r < 0.5) {
            points[0].set(0, random(0, height), 0);
            points[nbPoints-1].set(width, random(0, height), 0);
        } else {
            points[0].set(random(0, width), 0, 0);
            points[nbPoints-1].set(random(0, width), height, 0);
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
    
    // generate motion parameters
    void genMotionParams() {
        genPtsMotionParams();
        genCtrlPtsMotionParams();
    }
    
    // generate motion parameters for position points
    void genPtsMotionParams() {
        float a, b, xCenterOrig, yCenterOrig, xCenterTemp, yCenterTemp, theta;
        for (int i = 0; i < nbPoints; i++) {
            if (i == 0 || i == nbPoints - 1) {
                a = 0;
                b = 0;
                theta = 0;
                xCenterOrig = points[i].x;
                yCenterOrig = points[i].y;
            } else {
                a = random(POINT_MOTION_ELLIPSE_MIN_RADIUS, POINT_MOTION_ELLIPSE_MAX_RADIUS);
                b = random(POINT_MOTION_ELLIPSE_MIN_RADIUS, POINT_MOTION_ELLIPSE_MAX_RADIUS);
                theta = random(0, TWO_PI);
                xCenterOrig = points[i].x - a*cos(theta);
                yCenterOrig = points[i].y - b*cos(theta);
            }
            xCenterTemp = xCenterOrig;
            yCenterTemp = yCenterOrig;
            
            pointsMotionParams[i][0] = a;
            pointsMotionParams[i][1] = b;
            pointsMotionParams[i][2] = xCenterOrig;
            pointsMotionParams[i][3] = yCenterOrig;
            pointsMotionParams[i][4] = xCenterTemp;
            pointsMotionParams[i][5] = yCenterTemp;
            pointsMotionParams[i][6] = theta;
        }
    }
    
    // generate motion parameters for control points
    void genCtrlPtsMotionParams() {
        float a, b, xCenterOrig, yCenterOrig, xCenterTemp, yCenterTemp, theta;
        for (int j = 0; j < nbCtrlPoints; j++) {
            a = random(CTRL_POINT_MOTION_ELLIPSE_MIN_RADIUS, CTRL_POINT_MOTION_ELLIPSE_MAX_RADIUS);
            b = random(CTRL_POINT_MOTION_ELLIPSE_MIN_RADIUS, CTRL_POINT_MOTION_ELLIPSE_MAX_RADIUS);
            theta = random(0, TWO_PI);
            xCenterOrig = ctrlPoints[j].x - a*cos(theta);
            yCenterOrig = ctrlPoints[j].y - b*cos(theta);
            xCenterTemp = xCenterOrig;
            yCenterTemp = yCenterOrig;
            ctrlPointsMotionParams[j][0] = a;
            ctrlPointsMotionParams[j][1] = b;
            ctrlPointsMotionParams[j][2] = xCenterOrig;
            ctrlPointsMotionParams[j][3] = yCenterOrig;
            ctrlPointsMotionParams[j][4] = xCenterTemp;
            ctrlPointsMotionParams[j][5] = yCenterTemp;
            ctrlPointsMotionParams[j][6] = theta;
        }        
    }
    
    // animate Bezier curve
    void move() {
        movePts();
        moveCtrlPts();
    }
    
    // make position points move on their ellipse trajectories
    // (except for the first and last one)
    void movePts() {
        for (int i = 1; i < nbPoints - 1; i++) {
            movePt(i);
        }
    }
    
    // move single position point
    void movePt(int i) {
        float a, b, xCenterTemp, yCenterTemp, theta;
        a = pointsMotionParams[i][0];
        b = pointsMotionParams[i][1];
        xCenterTemp = pointsMotionParams[i][4];
        yCenterTemp = pointsMotionParams[i][5];
        theta = pointsMotionParams[i][6];
        theta = (theta + POINT_ANGLE_INCREMENT) % TWO_PI;
        points[i].set(xCenterTemp + a*cos(theta), yCenterTemp + b*sin(theta), 0);
        pointsMotionParams[i][6] = theta;
    }
    
    // make control points move on their ellipse trajectories
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
        float a, b, xCenterTemp, yCenterTemp, theta;
        a = ctrlPointsMotionParams[j][0];
        b = ctrlPointsMotionParams[j][1];
        xCenterTemp = ctrlPointsMotionParams[j][4];
        yCenterTemp = ctrlPointsMotionParams[j][5];
        theta = ctrlPointsMotionParams[j][6];
        theta = (theta + CTRL_POINT_ANGLE_INCREMENT) % TWO_PI;
        ctrlPoints[j].set(xCenterTemp + a*cos(theta), yCenterTemp + b*sin(theta), 0);
        ctrlPointsMotionParams[j][6] = theta;
    }
    
    // project control point on given line
    void moveCtrlPtOnLine(int i, int j1, int j2) {
        PVector dir = PVector.sub(points[i], ctrlPoints[j1]);
        dir.div(dir.mag());
        PVector ctrlPt1ToCtrlPt2 = PVector.sub(ctrlPoints[j2], ctrlPoints[j1]);
        PVector proj = PVector.mult(dir, PVector.dot(dir, ctrlPt1ToCtrlPt2));
        ctrlPoints[j2] = PVector.add(ctrlPoints[j1], proj);
    }
    
    // make curve interact with detected blobs
    // (curve should avoid approaching blobs)
    void interact(Blob[] blobs) {
        if (blobs != null && blobs.length > 0) {
            int[] nearestMotionCentersPointsIndices = null;
            int indexPt, indexCtrlPt1, indexCtrlPt2;
            PVector blobPos = new PVector();
            PVector pt = new PVector();
            PVector centerOrigPt = new PVector();
            PVector centerOrigCtrlPt1 = new PVector();
            PVector centerOrigCtrlPt2 = new PVector();
            PVector centerTempPt, centerTempCtrlPt1, centerTempCtrlPt2;
            PVector direction, displacement;
            float distance;
            
            for (int i = 0; i < blobs.length; i++) {
                blobPos.set(blobs[i].centroid.x, blobs[i].centroid.y, 0);
                //blobPos.set(mouseX, mouseY, 0);
                
                nearestMotionCentersPointsIndices = getNearestMotionCentersPointsIndices(blobPos);
                
                if (nearestMotionCentersPointsIndices != null && nearestMotionCentersPointsIndices.length > 0) {
                    for (int k = 0; k < nearestMotionCentersPointsIndices.length; k++) {
                        indexPt = nearestMotionCentersPointsIndices[k];
                        if (indexPt != 0 && indexPt != nbPoints - 1) {
                            indexCtrlPt1 = indexPt*2 - 1;
                            indexCtrlPt2 = indexPt*2;
                            
                            centerOrigPt.set(pointsMotionParams[indexPt][2], pointsMotionParams[indexPt][3], 0);
                            centerOrigCtrlPt1.set(ctrlPointsMotionParams[indexCtrlPt1][2], ctrlPointsMotionParams[indexCtrlPt1][3], 0);
                            centerOrigCtrlPt2.set(ctrlPointsMotionParams[indexCtrlPt2][2], ctrlPointsMotionParams[indexCtrlPt2][3], 0);
                            
                            pt.set(points[indexPt].x, points[indexPt].y, 0);
                            distance = (PVector.sub(centerOrigPt, blobPos)).mag();
                            direction = PVector.sub(pt, blobPos);
                            direction.div(direction.mag());
                            displacement = PVector.mult(direction, NEAREST_MOTION_ELLIPSE_RADIUS - distance);
                            
                            centerTempPt = PVector.add(centerOrigPt, displacement);
                            centerTempCtrlPt1 = PVector.add(centerOrigCtrlPt1, displacement);
                            centerTempCtrlPt2 = PVector.add(centerOrigCtrlPt2, displacement);
                            
                            pointsMotionParams[indexPt][4] = centerTempPt.x;
                            pointsMotionParams[indexPt][5] = centerTempPt.y;
                            ctrlPointsMotionParams[indexCtrlPt1][4] = centerTempCtrlPt1.x;
                            ctrlPointsMotionParams[indexCtrlPt1][5] = centerTempCtrlPt1.y;
                            ctrlPointsMotionParams[indexCtrlPt2][4] = centerTempCtrlPt2.x;
                            ctrlPointsMotionParams[indexCtrlPt2][5] = centerTempCtrlPt2.y;
                        }
                    }
                }
            }
        }
    }
    
    // get array of indices of position points having their motion ellipse centers
    // near particular point pt
    int[] getNearestMotionCentersPointsIndices(PVector pt) {
        int[] nearestMtnCenterPtsIdcs = null;
        int[] tmpIdcs = new int[nbPoints];
        PVector mtnCenter = new PVector();
        float distance;
        
        int count = 0;
        for (int i = 0; i < nbPoints; i++) {
            float xCenterOrig = pointsMotionParams[i][2];
            float yCenterOrig = pointsMotionParams[i][3];
            mtnCenter.set(xCenterOrig, yCenterOrig, 0);
            
            distance = (PVector.sub(mtnCenter, pt)).mag();
            if (distance <= NEAREST_MOTION_ELLIPSE_RADIUS) {
                tmpIdcs[count] = i;
                count++;
            }
        }
        if (count > 0) {
            nearestMtnCenterPtsIdcs = new int[count];
            for (int k = 0; k < count; k++) {
                nearestMtnCenterPtsIdcs[k] = tmpIdcs[k];
            }
        }
        return nearestMtnCenterPtsIdcs;
    }
    
    // decrease number of position points
    void decreaseNbPoints() {
        if (nbPoints > MIN_NB_POINTS) {
            nbPoints--;
            nbCtrlPoints = 2*nbPoints - 2;
            
            boolean fixedFirstLastPts = true;
            initialize(fixedFirstLastPts);
            generate(fixedFirstLastPts);
        }
    }
    
    // increase number of position points
    void increaseNbPoints() {
        if (nbPoints < MAX_NB_POINTS) {
            nbPoints++;
            nbCtrlPoints = 2*nbPoints - 2;
            
            boolean fixedFirstLastPts = true;
            initialize(fixedFirstLastPts);
            generate(fixedFirstLastPts);
        }
    }
    
    // regenerate curve
    void reset() {
        boolean fixedFirstLastPts = false;
        generate(fixedFirstLastPts);
    }
    
    // launch activity (set to running state so that curve is displayed)
    void launch() {
        state = S_RUNNING;
    }
    
    // check whether maze is in initialization state
    boolean isInInitState() {
        return (state == S_INIT);
    }
    
    // toggle graphical debug informations
    void toggleDebugDisplay() {
        debugDisplay = !debugDisplay;
    }
    
    // draw Bezier curve on screen
    void draw() {
        switch (state) {
            case S_INIT:
                // draw nothing
                break;
            case S_RUNNING:
                if (debugDisplay) {
                    drawDebug();
                }
                drawCurve();
            default:
                break;
        }
    }
    
    // draw debug information on points
    void drawDebug() {
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
    }
    
    // draw curve
    void drawCurve() {
        stroke(CURVE_COLOR);
        strokeWeight(CURVE_STROKE_WEIGHT);
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
}

