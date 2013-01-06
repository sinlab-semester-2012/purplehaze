import krister.Ess.*;

class BezierWall {
    
    //----------CLASS CONSTANTS-------------------------------------------------
    
    final boolean DEBUG_MOUSE = false;

    
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
    
    final float MIN_NOISE_VOLUME = 0.2;
    final int MIN_SINE_WAVE_HZ = 250;
    final int MAX_SINE_WAVE_HZ = 500;
    final float MAX_NOISE_VOLUME_DISTANCE = max(width, height)/2;
    final float MAX_SINE_VOLUME_DISTANCE = min(width, height)/2;
    
    final float MAX_DISPLACEMENT_DISTANCE = 0.2*(width + height);
    final int MAX_DISPLACEMENT_DISTANCE_DIV = 16;
    final float DISPLACEMENT_MAGNITUDE_FACTOR = 0.75;
    
    final color CURVE_COLOR = color(255);
    final float CURVE_STROKE_WEIGHT = 0.01*(width + height);
    
    //----------CLASS ATTRIBUTES------------------------------------------------
    
    int nbPoints;
    int nbCtrlPoints;
    PVector[] points;
    float[][] pointsMotionParams;
    PVector[] ctrlPoints;
    float[][] ctrlPointsMotionParams;
    
    AudioChannel pinkNoiseChannel;
    ArrayList<AudioChannel> sineWaveChannels;
    
    int state;
    static final int S_INIT = 0;
    static final int S_RUNNING = 1;
    static final int SSIZE = 2;
    
    boolean debugDisplay;

    //----------CONSTRUCTION, INTIALIZATION AND GENERATION------------------

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
        initializePoints(fixedFirstLastPts);
        initializeSounds();
    }
    
    // initialize point data
    void initializePoints(boolean fixedFirstLastPts) {
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
    
    // initialize sound data
    void initializeSounds() {
        pinkNoiseChannel = new AudioChannel();
        sineWaveChannels = new ArrayList<AudioChannel>();
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
            points[0].set(0, floor(random(0, height)), 0);
            points[nbPoints-1].set(width - 1, floor(random(0, height)), 0);
        } else {
            points[0].set(floor(random(0, width)), 0, 0);
            points[nbPoints-1].set(floor(random(0, width)), height - 1, 0);
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
    
    //----------CURVE MOVEMENT--------------------------------------------------
    
    // animate Bezier curve
    void move() {
        movePts();
        moveCtrlPts();
    }
    
    // make position points move on their ellipse trajectories
    // (except for the first and last one, for which we set to 
    // their position to their ellipse center but make them not 
    // move)
    void movePts() {
        points[0].set(pointsMotionParams[0][4], pointsMotionParams[0][5], 0);
        points[nbPoints - 1].set(pointsMotionParams[nbPoints - 1][4], pointsMotionParams[nbPoints - 1][5], 0);
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
    
    //----------CURVE INTERACTION-----------------------------------------------
    
    // make wall interact with detected blobs
    void interact(Blob[] blobs) {
        if (blobs != null && state == S_RUNNING) {
            generateAndPlaySounds(blobs);
            if (blobs.length > 0) {
                changeSoundsVolumes(blobs);
                displaceCurve(blobs);
            }
        }
    }
    
    // generate and play sounds
    // (pink noise is played and each blob is assigned a sine wave)
    void generateAndPlaySounds(Blob[] blobs) {
        if (pinkNoiseChannel.state != Ess.PLAYING) {
            addPinkNoise();
        }
        if (blobs.length > sineWaveChannels.size()) {
            addSineWaves(blobs.length - sineWaveChannels.size());
        } else if (blobs.length < sineWaveChannels.size()) {
            removeSineWaves(sineWaveChannels.size() - blobs.length);
        }
    }
    
    // add pink noise to current audio channels
    void addPinkNoise() {
        pinkNoiseChannel.initChannel(pinkNoiseChannel.frames(2000));
        PinkNoise pinkNoise = new PinkNoise(1.0);
        pinkNoise.generate(pinkNoiseChannel);
        pinkNoiseChannel.volume(MIN_NOISE_VOLUME);
        pinkNoiseChannel.play(Ess.FOREVER);
    }
    
    // add sinewaves to current audio channels
    void addSineWaves(int nbWavesToAdd) {
        for (int i = 0; i < nbWavesToAdd; i++) {
            AudioChannel sineWaveChannel = new AudioChannel();
            sineWaveChannel.initChannel(sineWaveChannel.frames(2000));
            SineWave sineWave = new SineWave(floor(random(MIN_SINE_WAVE_HZ, MAX_SINE_WAVE_HZ)), 1.0);
            sineWave.generate(sineWaveChannel);
            sineWaveChannel.volume(0.0);
            sineWaveChannel.play(Ess.FOREVER);
            sineWaveChannels.add(sineWaveChannel);
        }
    }
    
    // remove sinewaves at random from current audio channels
    void removeSineWaves(int nbWavesToRemove) {
        int indexToRemove = 0;
        for (int i = 0; i < nbWavesToRemove; i++) {
            indexToRemove = floor(random(sineWaveChannels.size()));
            sineWaveChannels.get(indexToRemove).destroy();
            sineWaveChannels.remove(indexToRemove);
        }
    }
    
    // change volumes of each sound depending on blobs locations
    void changeSoundsVolumes(Blob[] blobs) {
        setPinkNoiseVolume(blobs);
        setSineWaveVolumes(blobs);
    }
    
    // change volume of pink noise according to closest blob to curve
    // (approximate curve with two closest position points)
    void setPinkNoiseVolume(Blob[] blobs) {
        int[] nearestPositionPointsIndices;
        PVector blobPos, pt1, pt2, blobPosProj;
        float distance, minDistance = MAX_FLOAT;
        float volume;
        
        for (int i = 0; i < blobs.length; i++) {
            if (DEBUG_MOUSE) {
                blobPos = new PVector(mouseX, mouseY, 0);
            } else {
                blobPos = new PVector(blobs[i].centroid.x, blobs[i].centroid.y, 0);
            }
            nearestPositionPointsIndices = getNearestPositionPointsIndices(blobPos);
            pt1 = points[nearestPositionPointsIndices[0]];
            pt2 = points[nearestPositionPointsIndices[1]];
            blobPosProj = getProjection(blobPos, pt1, pt2);
            distance = (PVector.sub(blobPosProj, blobPos)).mag();
            if (distance < minDistance) {
                minDistance = distance;
            }
        }
        
        volume = max(MIN_NOISE_VOLUME, (MAX_NOISE_VOLUME_DISTANCE - minDistance)/MAX_NOISE_VOLUME_DISTANCE);
        pinkNoiseChannel.volume(volume);
    }
    
    // change volumes of each sine wave according to distance of corresp. blob to curve
    // (approximate curve with two closest position points)
    void setSineWaveVolumes(Blob[] blobs) {
        int[] nearestPositionPointsIndices;
        PVector blobPos, pt1, pt2, blobPosProj;
        float distance;
        float volume;
        
        for (int i = 0; i < blobs.length; i++) {
            if (DEBUG_MOUSE) {
                blobPos = new PVector(mouseX, mouseY, 0);
            } else {
                blobPos = new PVector(blobs[i].centroid.x, blobs[i].centroid.y, 0);
            }
            nearestPositionPointsIndices = getNearestPositionPointsIndices(blobPos);
            pt1 = points[nearestPositionPointsIndices[0]];
            pt2 = points[nearestPositionPointsIndices[1]];
            blobPosProj = getProjection(blobPos, pt1, pt2);
            distance = (PVector.sub(blobPosProj, blobPos)).mag();
            
            volume = max(0, (MAX_SINE_VOLUME_DISTANCE - distance)/MAX_SINE_VOLUME_DISTANCE);
            sineWaveChannels.get(i).volume(volume);
        }
    }
    
    // stop all sounds
    void stopSounds() {
        pinkNoiseChannel.destroy();
        for (AudioChannel sineWaveChannel : sineWaveChannels) {
            sineWaveChannel.destroy();
        }
    }
    
    // make curve avoid approaching blobs
    // (approximate curve with two closest motion centers of position points)
    void displaceCurve(Blob[] blobs) {
        int[] nearestMotionCentersPointsIndices;
        int i1, i2;
        PVector blobPos;
        PVector centerOrigPt1, centerOrigPt2;
        PVector blobPosProj, direction, displacement, displacement1, displacement2, displacementAxisProj;
        float distance, distanceRatio1, distanceRatio2, magnitude;
        PVector centerTempPt1;
        PVector centerOrigCtrlPt11, centerOrigCtrlPt12, centerTempCtrlPt11, centerTempCtrlPt12;
        PVector centerTempPt2;
        PVector centerOrigCtrlPt21, centerOrigCtrlPt22, centerTempCtrlPt21, centerTempCtrlPt22;
        
        for (int i = 0; i < blobs.length; i++) {
            if (DEBUG_MOUSE) {
                blobPos = new PVector(mouseX, mouseY, 0);
            } else {
                blobPos = new PVector(blobs[i].centroid.x, blobs[i].centroid.y, 0);
            }
            nearestMotionCentersPointsIndices = getNearestMotionCentersPointsIndices(blobPos);
            i1 = nearestMotionCentersPointsIndices[0];
            i2 = nearestMotionCentersPointsIndices[1];
            
            centerOrigPt1 = new PVector(pointsMotionParams[i1][2], pointsMotionParams[i1][3], 0);
            centerOrigPt2 = new PVector(pointsMotionParams[i2][2], pointsMotionParams[i2][3], 0);
            // get projected blob position on line defined by the two nearest motion centers
            blobPosProj = getProjection(blobPos, centerOrigPt1, centerOrigPt2);
            // compute distance from blob position to projected blob position
            distance = (PVector.sub(blobPosProj, blobPos)).mag();
            // compute distance ratios that will influence displacement magnitude for each motion center
            distanceRatio1 = (PVector.sub(centerOrigPt2, blobPosProj)).mag()/(PVector.sub(centerOrigPt1, centerOrigPt2)).mag();
            distanceRatio2 = (PVector.sub(centerOrigPt1, blobPosProj)).mag()/(PVector.sub(centerOrigPt1, centerOrigPt2)).mag();
            // compute direction of displacement
            direction = PVector.div(PVector.sub(blobPosProj, blobPos), distance);
            // compute magnitude of displacement
            // (if-else block needed for smooth visual change)
            if (distance > MAX_DISPLACEMENT_DISTANCE/MAX_DISPLACEMENT_DISTANCE_DIV) {
                magnitude = max(0, MAX_DISPLACEMENT_DISTANCE - distance);
            } else {
                magnitude = distance*(MAX_DISPLACEMENT_DISTANCE_DIV - 1);
            }
            magnitude = DISPLACEMENT_MAGNITUDE_FACTOR*magnitude;
            // compute general displacement, and specific displacements for both motion centers
            displacement = PVector.mult(direction, magnitude);
            displacement1 = PVector.mult(displacement, distanceRatio1);
            displacement2 = PVector.mult(displacement, distanceRatio2);
            
            // take care of first nearest motion center
            if (i1 != 0 && i1 != nbPoints - 1) {
                // move motion center
                centerTempPt1 = PVector.add(centerOrigPt1, displacement1);
                pointsMotionParams[i1][4] = centerTempPt1.x;
                pointsMotionParams[i1][5] = centerTempPt1.y;
                
                // move motion centers of corresp. control points
                centerOrigCtrlPt11 = new PVector(ctrlPointsMotionParams[2*i1 - 1][2], ctrlPointsMotionParams[2*i1 - 1][3], 0);
                centerOrigCtrlPt12 = new PVector(ctrlPointsMotionParams[2*i1][2], ctrlPointsMotionParams[2*i1][3], 0);
                centerTempCtrlPt11 = PVector.add(centerOrigCtrlPt11, displacement1);
                centerTempCtrlPt12 = PVector.add(centerOrigCtrlPt12, displacement1);
                ctrlPointsMotionParams[2*i1 - 1][4] = centerTempCtrlPt11.x;
                ctrlPointsMotionParams[2*i1 - 1][5] = centerTempCtrlPt11.y;
                ctrlPointsMotionParams[2*i1][4] = centerTempCtrlPt12.x;
                ctrlPointsMotionParams[2*i1][5] = centerTempCtrlPt12.y;
            } else { // first nearest motion center is an end point
                // move motion center along the x or y axis
                // (we want to keep it attached to the border)
                displacementAxisProj = new PVector();
                if (centerOrigPt1.x == 0 || centerOrigPt1.x == width - 1) {
                    displacementAxisProj.set(0, displacement1.y, 0);
                } else if (centerOrigPt1.y == 0 || centerOrigPt1.y == height - 1) {
                    displacementAxisProj.set(displacement1.x, 0, 0);
                }
                
                centerTempPt1 = PVector.add(centerOrigPt1, displacementAxisProj);
                pointsMotionParams[i1][4] = centerTempPt1.x;
                pointsMotionParams[i1][5] = centerTempPt1.y;
                
                // move motion centers of corresp. control point
                if (i1 == 0) {
                    centerOrigCtrlPt12 = new PVector(ctrlPointsMotionParams[0][2], ctrlPointsMotionParams[0][3], 0);
                    centerTempCtrlPt12 = PVector.add(centerOrigCtrlPt12, displacement1);
                    ctrlPointsMotionParams[0][4] = centerTempCtrlPt12.x;
                    ctrlPointsMotionParams[0][5] = centerTempCtrlPt12.y;
                } else if (i1 == nbPoints - 1) {
                    centerOrigCtrlPt11 = new PVector(ctrlPointsMotionParams[nbCtrlPoints - 1][2], ctrlPointsMotionParams[nbCtrlPoints - 1][3], 0);
                    centerTempCtrlPt11 = PVector.add(centerOrigCtrlPt11, displacement1);
                    ctrlPointsMotionParams[nbCtrlPoints - 1][4] = centerTempCtrlPt11.x;
                    ctrlPointsMotionParams[nbCtrlPoints - 1][5] = centerTempCtrlPt11.y;
                }
            }
            
            // take care of second nearest motion center
            if (i2 != 0 && i2 != nbPoints - 1) {
                centerTempPt2 = PVector.add(centerOrigPt2, displacement2);
                pointsMotionParams[i2][4] = centerTempPt2.x;
                pointsMotionParams[i2][5] = centerTempPt2.y;
                
                centerOrigCtrlPt21 = new PVector(ctrlPointsMotionParams[2*i2 - 1][2], ctrlPointsMotionParams[2*i2 - 1][3], 0);
                centerOrigCtrlPt22 = new PVector(ctrlPointsMotionParams[2*i2][2], ctrlPointsMotionParams[2*i2][3], 0);
                centerTempCtrlPt21 = PVector.add(centerOrigCtrlPt21, displacement2);
                centerTempCtrlPt22 = PVector.add(centerOrigCtrlPt22, displacement2);
                ctrlPointsMotionParams[2*i2 - 1][4] = centerTempCtrlPt21.x;
                ctrlPointsMotionParams[2*i2 - 1][5] = centerTempCtrlPt21.y;
                ctrlPointsMotionParams[2*i2][4] = centerTempCtrlPt22.x;
                ctrlPointsMotionParams[2*i2][5] = centerTempCtrlPt22.y;
            } else { // second nearest motion center is an end point
                // move motion center along the x or y axis
                // (we want to keep it attached to the border)
                displacementAxisProj = new PVector();
                if (centerOrigPt2.x == 0 || centerOrigPt2.x == width - 1) {
                    displacementAxisProj.set(0, displacement2.y, 0);
                } else if (centerOrigPt2.y == 0 || centerOrigPt2.y == height - 1) {
                    displacementAxisProj.set(displacement2.x, 0, 0);
                }
                
                centerTempPt2 = PVector.add(centerOrigPt2, displacementAxisProj);
                pointsMotionParams[i2][4] = centerTempPt2.x;
                pointsMotionParams[i2][5] = centerTempPt2.y;
                
                // move motion centers of corresp. control point
                if (i2 == 0) {
                    centerOrigCtrlPt22 = new PVector(ctrlPointsMotionParams[0][2], ctrlPointsMotionParams[0][3], 0);
                    centerTempCtrlPt22 = PVector.add(centerOrigCtrlPt22, displacement2);
                    ctrlPointsMotionParams[0][4] = centerTempCtrlPt22.x;
                    ctrlPointsMotionParams[0][5] = centerTempCtrlPt22.y;
                } else if (i2 == nbPoints - 1) {
                    centerOrigCtrlPt21 = new PVector(ctrlPointsMotionParams[nbCtrlPoints - 1][2], ctrlPointsMotionParams[nbCtrlPoints - 1][3], 0);
                    centerTempCtrlPt21 = PVector.add(centerOrigCtrlPt21, displacement2);
                    ctrlPointsMotionParams[nbCtrlPoints - 1][4] = centerTempCtrlPt21.x;
                    ctrlPointsMotionParams[nbCtrlPoints - 1][5] = centerTempCtrlPt21.y;
                }
            }
        }
    }
    
    // get projection of point pt0 on line going through pt1 and pt2
    PVector getProjection(PVector pt0, PVector pt1, PVector pt2) {
        PVector dir, proj;
        float magn;
        
        dir = PVector.sub(pt2, pt1);
        dir = PVector.div(dir, dir.mag());
        magn = PVector.dot(dir, PVector.sub(pt0, pt1));
        
        proj = PVector.add(pt1, PVector.mult(dir, magn));
        return proj;
    }

    // get sorted array of position points indices (using insertion sort),
    // sorted according to distance from point pt to each position point,
    // in increasing order
    int[] getNearestPositionPointsIndices(PVector pt) {
        float[] distances = new float[nbPoints];
        ArrayList<Integer> nearestPosPtsIdcsL = new ArrayList<Integer>();
        
        for (int i = 0; i < nbPoints; i++) {
            distances[i] = (PVector.sub(points[i], pt)).mag();
        }
        nearestPosPtsIdcsL.add(0);
        for (int j = 1; j < nbPoints; j++) {
            int count = 0;
            while (count < nearestPosPtsIdcsL.size() && distances[j] > distances[nearestPosPtsIdcsL.get(count)]) {
                count++;
            }
            nearestPosPtsIdcsL.add(count, j);
        }
        
        int[] nearestPosPtsIdcs = new int[nbPoints];
        int i = 0;
        for (Integer index : nearestPosPtsIdcsL)
        {
            nearestPosPtsIdcs[i] = index;
            i++;
        }
        return nearestPosPtsIdcs;
    }
    
    // get sorted array of position points indices (using insertion sort),
    // sorted according to distance from point pt to their corresponding motion centers,
    // in increasing order
    int[] getNearestMotionCentersPointsIndices(PVector pt) {
        float[] distances = new float[nbPoints];
        float xCenterOrig, yCenterOrig;
        PVector motionCenter = new PVector();
        ArrayList<Integer> nearestMtnCtrsPtsIdcsL = new ArrayList<Integer>();
        
        for (int i = 0; i < nbPoints; i++) {
            xCenterOrig = pointsMotionParams[i][2];
            yCenterOrig = pointsMotionParams[i][3];
            motionCenter.set(xCenterOrig, yCenterOrig, 0);
            distances[i] = (PVector.sub(motionCenter, pt)).mag();
        }
        nearestMtnCtrsPtsIdcsL.add(0);
        for (int j = 1; j < nbPoints; j++) {
            int count = 0;
            while (count < nearestMtnCtrsPtsIdcsL.size() && distances[j] > distances[nearestMtnCtrsPtsIdcsL.get(count)]) {
                count++;
            }
            nearestMtnCtrsPtsIdcsL.add(count, j);
        }
        
        int[] nearestMtnCtrsPtsIdcs = new int[nbPoints];
        int i = 0;
        for (Integer index : nearestMtnCtrsPtsIdcsL)
        {
            nearestMtnCtrsPtsIdcs[i] = index;
            i++;
        }
        return nearestMtnCtrsPtsIdcs;
    }
    
    //----------CURVE PROPERTIES METHODS----------------------------------------
    
    // decrease number of position points
    void decreaseNbPoints() {
        if (nbPoints > MIN_NB_POINTS) {
            nbPoints--;
            nbCtrlPoints = 2*nbPoints - 2;
            
            stopSounds();
            
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
            
            stopSounds();
            
            boolean fixedFirstLastPts = true;
            initialize(fixedFirstLastPts);
            generate(fixedFirstLastPts);
        }
    }
    
    //----------CURVE REGENERATION----------------------------------------------
    
    // regenerate curve
    void reset() {
        stopSounds();
        
        boolean fixedFirstLastPts = false;
        initialize(fixedFirstLastPts);
        generate(fixedFirstLastPts);
    }
    
    //----------CURVE STATE METHODS---------------------------------------------
    
    // launch activity (set to running state so that curve is displayed)
    void launch() {
        state = S_RUNNING;
    }
    
    // check whether maze is in initialization state
    boolean isInInitState() {
        return (state == S_INIT);
    }
    
    //----------VISUAL DEBUGGING DISPLAY METHODS--------------------------------
    
    // toggle graphical debug informations
    void toggleDebugDisplay() {
        debugDisplay = !debugDisplay;
    }
    
    //----------DRAW METHODS----------------------------------------------------
    
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
            fill(255, 255, 0);
            ellipse(pointsMotionParams[m][2], pointsMotionParams[m][3], 7, 7);
            fill(255, 255, 0);
            ellipse(pointsMotionParams[m][4], pointsMotionParams[m][5], 7, 7);
            
            fill(255, 0, 0);
            ellipse(ctrlPoints[n].x, ctrlPoints[n].y, 10, 10);
            ellipse(ctrlPoints[n + 1].x, ctrlPoints[n + 1].y, 10, 10);
            strokeWeight(1);
            stroke(255, 0, 0);
            line(ctrlPoints[n].x, ctrlPoints[n].y, points[m].x, points[m].y);
            line(ctrlPoints[n + 1].x, ctrlPoints[n + 1].y, points[m].x, points[m].y);
            noStroke();
            fill(255, 0, 255);
            ellipse(ctrlPointsMotionParams[n][2], ctrlPointsMotionParams[n][3], 7, 7);
            ellipse(ctrlPointsMotionParams[n + 1][2], ctrlPointsMotionParams[n + 1][3], 7, 7);
            fill(255, 0, 255);
            ellipse(ctrlPointsMotionParams[n][4], ctrlPointsMotionParams[n][5], 7, 7);
            ellipse(ctrlPointsMotionParams[n + 1][4], ctrlPointsMotionParams[n + 1][5], 7, 7);
            
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

