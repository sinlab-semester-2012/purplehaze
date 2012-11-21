
class Cell {
    
    int xIndex;
    int yIndex;
    boolean rightWall;
    boolean topWall;
    boolean leftWall;
    boolean bottomWall;
    boolean isEntrance;
    
    Cell(int xInd, int yInd) {
        xIndex = xInd;
        yIndex = yInd;
        rightWall = true;
        topWall = true;
        leftWall = true;
        bottomWall = true;
        isEntrance = false;
    }
    
    Cell(int xInd, int yInd, boolean rightW, boolean topW, boolean leftW, boolean bottomW) {
        xIndex = xInd;
        yIndex = yInd;
        rightWall = rightW;
        topWall = topW;
        leftWall = leftW;
        bottomWall = bottomW;
        isEntrance = false;
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
    
    boolean isEntrance() {
        return isEntrance;
    }
    
    void setIsEntrance(boolean isE) {
        isEntrance = isE;
    }
}

