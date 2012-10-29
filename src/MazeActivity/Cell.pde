
class Cell {
    
    int x;
    int y;
    boolean rightWall;
    boolean topWall;
    boolean leftWall;
    boolean bottomWall;
    
    Cell(int xPos, int yPos) {
        x = xPos;
        y = yPos;
        rightWall = true;
        topWall = true;
        leftWall = true;
        bottomWall = true;
    }
    
    Cell(int xPos, int yPos, boolean rightW, boolean topW, boolean leftW, boolean bottomW) {
        x = xPos;
        y = yPos;
        rightWall = rightW;
        topWall = topW;
        leftWall = leftW;
        bottomWall = bottomW;
    }
    
    void setPos(int xPos, int yPos) {
        x = xPos;
        y = yPos;
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
    
    int getX() {
        return x;
    }
    
    int getY() {
        return y;
    }
}

