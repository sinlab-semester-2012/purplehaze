
class Maze {
    
    final float EDGE_WIDTH = 0.01*(width + height);
    
    final float GS_WON_LOST_DURATION_MS = 3000;
    final float GS_WON_LOST_FLICKER_DURATION_MS = 1000;
    
    int nbCellsX;
    int nbCellsY;
    float sizeCellX;
    float sizeCellY;
    Cell[][] cells;
    
    PVector playerPos;
    boolean playerEntered;
    
    int gameState;
    static final int GS_INIT = 0;
    static final int GS_PLAYING = 1;
    static final int GS_WON = 2;
    static final int GS_LOST = 3;
    static final int GSSIZE = 4;
    
    int prevMillis;
    
    Maze(int nbCX, int nbCY) {
        nbCellsX = nbCX;
        nbCellsY = nbCY;
        
        initialize();
        generate();
        
        playerPos = new PVector();
        playerEntered = false;
        gameState = GS_INIT;
        prevMillis = 0;
    }
    
    // initialize data
    void initialize() {
        sizeCellX = width/nbCellsX;
        sizeCellY = height/nbCellsY;
        cells = new Cell[nbCellsX][nbCellsY];
        for (int x = 0; x < nbCellsX; x++) {
            for (int y = 0; y < nbCellsY; y++) {
                cells[x][y] = new Cell(x, y);
            }
        }
    }
    
    // generate maze using backtracking depth-first search algorithm
    // (http://en.wikipedia.org/wiki/Maze_generation_algorithm#Recursive_backtracker)
    void generate() {
        Integer[] currentCellInd = new Integer[2];
        Integer[] neighbourCellInd = new Integer[2];
        Boolean[][] visitedCellInds = new Boolean[nbCellsX][nbCellsY];
        for (int x = 0; x < nbCellsX; x++) {
            for (int y = 0; y < nbCellsY; y++) {
                visitedCellInds[x][y] = false;
            }
        }
        Deque<Integer[]> cellStack = new ArrayDeque<Integer[]>();
        
        // 1. make initial cell the current cell and mark it as visited
        currentCellInd[0] = 0;
        currentCellInd[1] = 0;
        visitedCellInds[currentCellInd[0]][currentCellInd[1]] = true;
        
        // 2. while there are unvisited cells
        while (generateExistsUnvisited(visitedCellInds)) {
            // a. if current cell has any neighbours which have not been visited 
            if (generateHasUnvisitedNeighbours(visitedCellInds, currentCellInd)) {
                // i. choose randomly one of the unvisited neighbours
                neighbourCellInd = generatePickUnvisitedNeighbour(visitedCellInds, currentCellInd);
                // ii. push current cell to stack
                cellStack.push(currentCellInd);
                // iii. remove wall between current cell and chosen cell
                if (currentCellInd[0] != neighbourCellInd[0]) {
                    int x1 = min(currentCellInd[0], neighbourCellInd[0]);
                    int x2 = x1 + 1;
                    int y = currentCellInd[1];
                    cells[x1][y].setRightWall(false);
                    cells[x2][y].setLeftWall(false);
                } else if (currentCellInd[1] != neighbourCellInd[1]) {
                    int x = currentCellInd[0];
                    int y1 = min(currentCellInd[1], neighbourCellInd[1]);
                    int y2 = y1 + 1;
                    cells[x][y1].setBottomWall(false);
                    cells[x][y2].setTopWall(false);
                }
                // iv. make chosen cell the current cell and mark it as visited
                currentCellInd = neighbourCellInd;
                visitedCellInds[currentCellInd[0]][currentCellInd[1]] = true;
            // b. else if stack is not empty 
            } else if (!cellStack.isEmpty()) {
                // i. pop cell from the stack, make it the current cell
                currentCellInd = cellStack.pop();
            // c. else
            } else {
                // i. pick random cell, make it the current cell and mark it as visited
                currentCellInd = generatePickRandomUnvisited(visitedCellInds);
                visitedCellInds[currentCellInd[0]][currentCellInd[1]] = true;
            }
        }
        
        // 3. pick entry and exit of maze
        generatePickEntryAndExit();
    }
    
    // used only in generate(): check whether there are unvisited cells
    boolean generateExistsUnvisited(Boolean[][] visitedCellInds) {
        for (int x = 0; x < nbCellsX; x++) {
            for (int y = 0; y < nbCellsY; y++) {
                if (!visitedCellInds[x][y]) {
                    return true;
                }
            }
        }
        return false;
    }
    
    // used only in generate(): check whether cell has unvisited neighbours
    boolean generateHasUnvisitedNeighbours(Boolean[][] visitedCellInds, Integer[] cellInd) {
        int x = cellInd[0];
        int y = cellInd[1];
        if (x == 0) {
            if (y == 0) {
                return (!visitedCellInds[x + 1][y] || !visitedCellInds[x][y + 1]);
            } else if (y == nbCellsY - 1) {
                return (!visitedCellInds[x + 1][y] || !visitedCellInds[x][y - 1]);
            } else {
                return (!visitedCellInds[x + 1][y] || !visitedCellInds[x][y + 1] || !visitedCellInds[x][y - 1]);
            }
        } else if (x == nbCellsX - 1) {
            if (y == 0) {
                return (!visitedCellInds[x - 1][y] || !visitedCellInds[x][y + 1]);
            } else if (y == nbCellsY - 1) {
                return (!visitedCellInds[x - 1][y] || !visitedCellInds[x][y - 1]);
            } else {
                return (!visitedCellInds[x - 1][y] || !visitedCellInds[x][y + 1] || !visitedCellInds[x][y - 1]);
            }
        } else {
            if (y == 0) {
                return (!visitedCellInds[x + 1][y] || !visitedCellInds[x - 1][y] || !visitedCellInds[x][y + 1]);
            } else if (y == nbCellsY - 1) {
                return (!visitedCellInds[x + 1][y] || !visitedCellInds[x - 1][y] || !visitedCellInds[x][y - 1]);
            } else {
                return (!visitedCellInds[x + 1][y] || !visitedCellInds[x - 1][y] || !visitedCellInds[x][y + 1] || !visitedCellInds[x][y - 1]);
            }
        }
    }
    
    // used only in generate(): pick random unvisited neighbour from cell
    Integer[] generatePickUnvisitedNeighbour(Boolean[][] visitedCellInds, Integer[] cellInd) {
        Integer[][] unvisitedNeighbourCellInds = new Integer[4][2];
        int count = 0;
        Integer[] neighbourCellInd = new Integer[2];
        
        int x = cellInd[0];
        int y = cellInd[1];
        if (x == 0) {
            if (y == 0) {
                if (!visitedCellInds[x + 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x + 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x][y + 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y + 1;
                   count++;
                }
            } else if (y == nbCellsY - 1) {
                if (!visitedCellInds[x + 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x + 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x][y - 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y - 1;
                   count++;
                }
            } else {
                if (!visitedCellInds[x + 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x + 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x][y + 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y + 1;
                   count++;
                }
                if (!visitedCellInds[x][y - 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y - 1;
                   count++;
                }
            }
        } else if (x == nbCellsX - 1) {
            if (y == 0) {
                if (!visitedCellInds[x - 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x - 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x][y + 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y + 1;
                   count++;
                }
            } else if (y == nbCellsY - 1) {
                if (!visitedCellInds[x - 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x - 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x][y - 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y - 1;
                   count++;
                }
            } else {
                if (!visitedCellInds[x - 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x - 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x][y + 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y + 1;
                   count++;
                }
                if (!visitedCellInds[x][y - 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y - 1;
                   count++;
                }
            }
        } else {
            if (y == 0) {
                if (!visitedCellInds[x + 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x + 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x - 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x - 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x][y + 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y + 1;
                   count++;
                }
            } else if (y == nbCellsY - 1) {
                if (!visitedCellInds[x + 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x + 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x - 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x - 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x][y - 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y - 1;
                   count++;
                }
            } else {
                if (!visitedCellInds[x + 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x + 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x - 1][y]) {
                   unvisitedNeighbourCellInds[count][0] = x - 1;
                   unvisitedNeighbourCellInds[count][1] = y;
                   count++;
                } 
                if (!visitedCellInds[x][y + 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y + 1;
                   count++;
                }
                if (!visitedCellInds[x][y - 1]) {
                   unvisitedNeighbourCellInds[count][0] = x;
                   unvisitedNeighbourCellInds[count][1] = y - 1;
                   count++;
                }
            }
        }
        
        int r = floor(random(0, count));
        neighbourCellInd[0] = unvisitedNeighbourCellInds[r][0];
        neighbourCellInd[1] = unvisitedNeighbourCellInds[r][1];
        return neighbourCellInd;
    }
    
    // used only in generate(): pick random unvisited cell
    Integer[] generatePickRandomUnvisited(Boolean[][] visitedCellInds) {
        Integer[][] unvisitedCellInds = new Integer[nbCellsX*nbCellsY][2];
        int count = 0;
        Integer[] unvisitedCellInd = new Integer[2];
        
        for (int x = 0; x < nbCellsX; x++) {
            for (int y = 0; y < nbCellsY; y++) {
                if (!visitedCellInds[x][y]) {
                    unvisitedCellInds[count][0] = x;
                    unvisitedCellInds[count][1] = y;
                    count++;
                }
            }
        }
        
        int r = floor(random(0, count));
        unvisitedCellInd[0] = unvisitedCellInds[r][0];
        unvisitedCellInd[1] = unvisitedCellInds[r][1];
        return unvisitedCellInd;
    }
    
    // used only in generate(): pick entry and exit cells
    // (specific role will be determined when player enters maze by one of them)
    void generatePickEntryAndExit() {
        int r, x, y;
        
        for (int i = 0; i < 2; i++) {
            do {
                r = floor(random(0, 4));
                if (r == 0) {
                    x = 0;
                    y = floor(random(0, nbCellsY));
                } else if (r == 1) {
                    x = nbCellsX - 1;
                    y = floor(random(0, nbCellsY));
                } else if (r == 2) {
                    x = floor(random(0, nbCellsX));
                    y = 0;
                } else {
                    x = floor(random(0, nbCellsX));
                    y = nbCellsY - 1;
                }
            } while (cells[x][y].isEntryAndExit());
            cells[x][y].setAsEntryAndExit();
        }
    }
    
    // get cell in which player is positioned
    Cell getPlayerCell() {
        float xPos = playerPos.x;
        float yPos = playerPos.y;
        int x = floor((xPos - (xPos % sizeCellX))/sizeCellX);
        int y = floor((yPos - (yPos % sizeCellY))/sizeCellY);
        return cells[x][y];
    }
    
    // interact with detected blob (player)
    void interact(Blob[] blobs) {
        if (blobs != null && blobs.length > 0) {
            //playerPos.set(blobs[0].centroid.x, blobs[0].centroid.y, 0);
            playerPos.set(mouseX, mouseY, 0);
        }
    }
    
    // launch the game, i.e. set the game state accordingly
    void launch() {
        gameState = GS_PLAYING;
    }
    
    // update game
    void play() {
        switch (gameState) {
            case GS_INIT:
                // do nothing
                break;
            case GS_PLAYING:
                if (hasPlayerTouchedAWall()) {
                    if (!playerEntered) {
                        playerEntered = hasPlayerEntered();
                    } else if (hasPlayerReachedExit()) {
                        gameState = GS_WON;
                        prevMillis = millis();
                    } else {
                        gameState = GS_LOST;
                        prevMillis = millis();
                    }
                }
                break;
            case GS_WON:
                if ((millis() - prevMillis) > GS_WON_LOST_DURATION_MS) {
                    gameState = GS_INIT;
                    reset();
                }
                break;
            case GS_LOST:
                if ((millis() - prevMillis) > GS_WON_LOST_DURATION_MS) {
                    gameState = GS_INIT;
                    reset();
                }
                break;
            default:
                break;
        }
    }
    
    // test whether player has entered maze
    // and if so, update status of entry and exit cells
    boolean hasPlayerEntered() {
        boolean entered = false;
        
        Cell playerCell = getPlayerCell();
        int x = playerCell.getXIndex();
        int y = playerCell.getYIndex();
        float xPos = playerPos.x;
        float yPos = playerPos.y;
        
        if (cells[x][y].isEntryAndExit()) {
            if (cells[x][y].hasRightWall() && x == nbCellsX - 1) {
                entered = (abs(xPos - (x + 1)*sizeCellX) < EDGE_WIDTH/2);
            } else if (cells[x][y].hasTopWall() && y == 0) {
                entered = (abs(yPos - y*sizeCellY) < EDGE_WIDTH/2);
            } else if (cells[x][y].hasLeftWall() && x == 0) {
                entered = (abs(xPos - x*sizeCellX) < EDGE_WIDTH/2);
            } else if (cells[x][y].hasBottomWall() && y == nbCellsY - 1) {
                entered = (abs(yPos - (y + 1)*sizeCellY) < EDGE_WIDTH/2);
            }
        }
        if (entered) {
            cells[x][y].setAsEntry();
        }
        return entered;
    }
    
    // test whether player reached the exit
    boolean hasPlayerReachedExit() {
        boolean reachedExit = false;
        
        Cell playerCell = getPlayerCell();
        int x = playerCell.getXIndex();
        int y = playerCell.getYIndex();
        float xPos = playerPos.x;
        float yPos = playerPos.y;
        
        if (cells[x][y].isExit()) {
            if (cells[x][y].hasRightWall() && x == nbCellsX - 1) {
                reachedExit = (abs(xPos - (x + 1)*sizeCellX) < EDGE_WIDTH/2);
            } else if (cells[x][y].hasTopWall() && y == 0) {
                reachedExit = (abs(yPos - y*sizeCellY) < EDGE_WIDTH/2);
            } else if (cells[x][y].hasLeftWall() && x == 0) {
                reachedExit = (abs(xPos - x*sizeCellX) < EDGE_WIDTH/2);
            } else if (cells[x][y].hasBottomWall() && y == nbCellsY - 1) {
                reachedExit = (abs(yPos - (y + 1)*sizeCellY) < EDGE_WIDTH/2);
            }
        }
        return reachedExit;
    }
    
    // test for collision between walls and player
    boolean hasPlayerTouchedAWall() {
        boolean touchedAWall = false;
        
        Cell playerCell = getPlayerCell();
        int x = playerCell.getXIndex();
        int y = playerCell.getYIndex();
        float xPos = playerPos.x;
        float yPos = playerPos.y;
        
        if (cells[x][y].hasRightWall()) {
            touchedAWall = (abs(xPos - (x + 1)*sizeCellX) < EDGE_WIDTH/2);
        }
        if (cells[x][y].hasTopWall()) {
            touchedAWall = (abs(yPos - y*sizeCellY) < EDGE_WIDTH/2);
        }
        if (cells[x][y].hasLeftWall()) {
            touchedAWall = (abs(xPos - x*sizeCellX) < EDGE_WIDTH/2);
        }
        if (cells[x][y].hasBottomWall()) {
            touchedAWall = (abs(yPos - (y + 1)*sizeCellY) < EDGE_WIDTH/2);
        }
        return touchedAWall;
    }
    
    // reset maze
    void reset() {
        initialize();
        generate();
    }
    
    // check whether maze is in GS_INIT state
    boolean isInInitState() {
        return (gameState == GS_INIT);
    }
    
    // draw maze and maze objects
    void draw() {
        switch (gameState) {
            case GS_INIT:
                drawWalls(color(255));
                drawEntryAndExit(color(0, 255, 0));
                break;
            case GS_PLAYING:
                drawNearestWalls(color(255));
                drawEntryAndExit(color(0, 255, 0));
                break;
            case GS_WON:
                if (millis() % GS_WON_LOST_FLICKER_DURATION_MS < GS_WON_LOST_FLICKER_DURATION_MS/2) {
                    drawWalls(color(0, 255, 0));
                }
                break;
            case GS_LOST:
                if (millis() % GS_WON_LOST_FLICKER_DURATION_MS < GS_WON_LOST_FLICKER_DURATION_MS/2) {
                    drawWalls(color(255, 0, 0));
                }
                break;
            default:
                break;
        }
    }
    
    // draw walls of maze
    void drawWalls(color c) {
        stroke(c);
        strokeWeight(EDGE_WIDTH);
        strokeCap(ROUND);
        for (int x = 0; x < nbCellsX; x++) {
            for (int y = 0; y < nbCellsY; y++) {
                if (cells[x][y].hasRightWall()) {
                    line((x + 1)*sizeCellX - 1, y*sizeCellY, (x + 1)*sizeCellX - 1, (y + 1)*sizeCellY - 1);
                }
                if (cells[x][y].hasTopWall()) {
                    line(x*sizeCellX, y*sizeCellY, (x + 1)*sizeCellX - 1, y*sizeCellY);
                }
                if (cells[x][y].hasLeftWall()) {
                    line(x*sizeCellX, y*sizeCellY, x*sizeCellX, (y + 1)*sizeCellY - 1);
                }
                if (cells[x][y].hasBottomWall()) {
                    line(x*sizeCellX, (y + 1)*sizeCellY - 1, (x + 1)*sizeCellX - 1, (y + 1)*sizeCellY - 1);
                }
            }
        }
    }
    
    void drawNearestWalls(color c) {
        Cell playerCell = getPlayerCell();
        int x = playerCell.getXIndex();
        int y = playerCell.getYIndex();
        
        stroke(c);
        strokeWeight(EDGE_WIDTH);
        strokeCap(ROUND);
        if (cells[x][y].hasRightWall()) {
            line((x + 1)*sizeCellX - 1, y*sizeCellY, (x + 1)*sizeCellX - 1, (y + 1)*sizeCellY - 1);
        }
        if (cells[x][y].hasTopWall()) {
            line(x*sizeCellX, y*sizeCellY, (x + 1)*sizeCellX - 1, y*sizeCellY);
        }
        if (cells[x][y].hasLeftWall()) {
            line(x*sizeCellX, y*sizeCellY, x*sizeCellX, (y + 1)*sizeCellY - 1);
        }
        if (cells[x][y].hasBottomWall()) {
            line(x*sizeCellX, (y + 1)*sizeCellY - 1, (x + 1)*sizeCellX - 1, (y + 1)*sizeCellY - 1);
        }
    }
    
    void drawEntryAndExit(color c) {
        stroke(c);
        strokeWeight(EDGE_WIDTH);
        strokeCap(ROUND);
        for (int x = 0; x < nbCellsX; x++) {
            for (int y = 0; y < nbCellsY; y++) {
                if (cells[x][y].isEntryAndExit()) {
                    if (cells[x][y].hasRightWall() && x == nbCellsX - 1) {
                        line((x + 1)*sizeCellX - 1, y*sizeCellY, (x + 1)*sizeCellX - 1, (y + 1)*sizeCellY - 1);
                    } else if (cells[x][y].hasTopWall() && y == 0) {
                        line(x*sizeCellX, y*sizeCellY, (x + 1)*sizeCellX - 1, y*sizeCellY);
                    } else if (cells[x][y].hasLeftWall() && x == 0) {
                        line(x*sizeCellX, y*sizeCellY, x*sizeCellX, (y + 1)*sizeCellY - 1);
                    } else if (cells[x][y].hasBottomWall() && y == nbCellsY - 1) {
                        line(x*sizeCellX, (y + 1)*sizeCellY - 1, (x + 1)*sizeCellX - 1, (y + 1)*sizeCellY - 1);
                    }
                }
            }
        }
    }
}

