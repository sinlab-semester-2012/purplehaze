
class FightingHalos {
    
    int state;
    static final int S_INIT = 0;
    static final int S_RUNNING = 1;
    static final int SSIZE = 2;

    FightingHalos() {
        state = S_INIT;
    }
    
    // interact with detected blobs (people)
    void interact(Blob[] blobs) {
        if (blobs != null && blobs.length > 0) {
            
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
                
            default:
                break;
        }
    }
}

