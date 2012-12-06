
class FightingHalos {
    
    Halo[] halos;
    
    int state;
    static final int S_INIT = 0;
    static final int S_RUNNING = 1;
    static final int SSIZE = 2;

    FightingHalos() {
        initialize();
        
        state = S_INIT;
    }
    
    // initialize data
    void initialize() {
        // DEBUG CODE
        halos = new Halo[2];
        halos[0] = new Halo(new PVector(0, 0, 0));
        halos[1] = new Halo(new PVector(300, 300, 0));
    }
    
    // interact with detected blobs (people)
    void interact(Blob[] blobs) {
        if (blobs != null && blobs.length > 0) {
            // DEBUG CODE
            PVector blob1Pos = new PVector();
            PVector blob2Pos = new PVector();
            //blob1Pos.set(blobs[0].centroid.x, blobs[0].centroid.y, 0);
            blob1Pos.set(mouseX, mouseY, 0);
            //blob2Pos.set(blobs[0].centroid.x, blobs[1].centroid.y, 0);
            
            halos[0].setPos(blob1Pos);
            //halos[1].setPos(blob2Pos);
        }
    }
        
    // launch activity (set to running state so that curve is displayed)
    void launch() {
        state = S_RUNNING;
    }
    
    // check whether maze is in initialization state
    boolean isInInitState() {
        return (state == S_INIT);
    }
    
    // draw Bezier curve on screen
    void draw() {
        switch (state) {
            case S_INIT:
                // draw nothing
                break;
            case S_RUNNING:
                // DEBUG CODE
                halos[0].draw();
                halos[1].draw();
            default:
                break;
        }
    }
}

