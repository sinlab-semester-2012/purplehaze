
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
    
    // get coordinate x index
    int getXIndex() {
        return xIndex;
    }
    
    // get coordinate y index
    int getYIndex() {
        return yIndex;
    }
    
    // set coordinate indices
    void setXYIndices(int xInd, int yInd) {
        xIndex = xInd;
        yIndex = yInd;
    }
    
    // check whether cell has right wall
    boolean hasRightWall() {
        return rightWall;
    }
    
    // check whether cell has top wall
    boolean hasTopWall() {
        return topWall;
    }
    
    // check whether cell has left wall
    boolean hasLeftWall() {
        return leftWall;
    }
    
    // check whether cell has bottom wall
    boolean hasBottomWall() {
        return bottomWall;
    }
    
    // add or remove right wall
    void setRightWall(boolean rightW) {
        rightWall = rightW;
    }
    
    // add or remove top wall
    void setTopWall(boolean topW) {
        topWall = topW;
    }
    
    // add or remove left wall
    void setLeftWall(boolean leftW) {
        leftWall = leftW;
    }
    
    // add or remove bottom wall
    void setBottomWall(boolean bottomW) {
        bottomWall = bottomW;
    }
    
    // check whether cell is an entrance cell
    boolean isEntrance() {
        return isEntrance;
    }
    
    // set cell as entrance or normal cell
    void setIsEntrance(boolean isE) {
        isEntrance = isE;
    }
}

