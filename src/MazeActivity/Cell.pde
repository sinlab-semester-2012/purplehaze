
class Cell {
    
    int xIndex;
    int yIndex;
    boolean rightWall;
    boolean topWall;
    boolean leftWall;
    boolean bottomWall;
    boolean isEntry;
    boolean isExit;
    
    Cell(int xInd, int yInd) {
        xIndex = xInd;
        yIndex = yInd;
        rightWall = true;
        topWall = true;
        leftWall = true;
        bottomWall = true;
        isEntry = false;
        isExit = false;
    }
    
    Cell(int xInd, int yInd, boolean rightW, boolean topW, boolean leftW, boolean bottomW) {
        xIndex = xInd;
        yIndex = yInd;
        rightWall = rightW;
        topWall = topW;
        leftWall = leftW;
        bottomWall = bottomW;
        isEntry = false;
        isExit = false;
    }
    
    int getXIndex() {
        return xIndex;
    }
    
    int getYIndex() {
        return yIndex;
    }
    
    void setXYIndices(int xInd, int yInd) {
        xIndex = xInd;
        yIndex = yInd;
    }
    
    boolean hasRightWall() {
        return rightWall;
    }
    
    boolean hasTopWall() {
        return topWall;
    }
    
    boolean hasLeftWall() {
        return leftWall;
    }
    
    boolean hasBottomWall() {
        return bottomWall;
    }
    
    void setRightWall(boolean rightW) {
        rightWall = rightW;
    }
    
    void setTopWall(boolean topW) {
        topWall = topW;
    }
    
    void setLeftWall(boolean leftW) {
        leftWall = leftW;
    }
    
    void setBottomWall(boolean bottomW) {
        bottomWall = bottomW;
    }
    
    void setAsEntryOrExit() {
        isEntry = true;
        isExit = true;
    }
    
    void setAsEntry() {
        isEntry = true;
        isExit = false;
    }
    
    void setAsExit() {
        isEntry = false;
        isExit = true;
    }
    
    boolean isEntryOrExit() {
        return (isEntry || isExit);
    }
    
    boolean isEntry() {
        return isEntry;
    }
    
    boolean isExit() {
        return isExit;
    }
}

