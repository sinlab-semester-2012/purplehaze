
class Maze {
    
    final float EDGE_WIDTH = 0.0075*(width + height);
    
    int nbCellsX;
    int nbCellsY;
    float sizeCellX;
    float sizeCellY;
    Cell[][] cells;
    
    PVector playerPos;
    
    Maze(int nbCX, int nbCY) {
        nbCellsX = nbCX;
        nbCellsY = nbCY;
        initialize();
        generate();
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
        playerPos = new PVector();
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
            } while (cells[x][y].isEntryOrExit());
            cells[x][y].setAsEntryOrExit();
        }
    }
    
    
    // interact with detected blob (player)
    void interact(Blob blob) {
        //playerPos.set(blob.centroid.x, blob.centroid.y, 0);
        playerPos.set(mouseX, mouseY, 0);
    }
    
    Cell getPlayerCell() {
        float xPos = playerPos.x;
        float yPos = playerPos.y;
        int x = floor((xPos - (xPos % sizeCellX))/sizeCellX);
        int y = floor((yPos - (yPos % sizeCellY))/sizeCellY);
        return cells[x][y];
    }
    
    // draw maze and maze objects
    void draw() {
        //drawWalls();
        drawNearestWalls();
        drawEntryAndExit();
    }
    
    // draw walls of maze
    void drawWalls() {
        stroke(255);
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
    
    void drawNearestWalls() {
        Cell cell = getPlayerCell();
        int x = cell.getXIndex();
        int y = cell.getYIndex();
        
        stroke(255);
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
    
    void drawEntryAndExit() {
        stroke(0, 255, 0);
        strokeWeight(EDGE_WIDTH);
        strokeCap(ROUND);
        for (int x = 0; x < nbCellsX; x++) {
            for (int y = 0; y < nbCellsY; y++) {
                if (cells[x][y].isEntryOrExit()) {
                    if (cells[x][y].hasRightWall() && x == nbCellsX - 1) {
                        line((x + 1)*sizeCellX - 1, y*sizeCellY, (x + 1)*sizeCellX - 1, (y + 1)*sizeCellY - 1);
                    }
                    if (cells[x][y].hasTopWall() && y == 0) {
                        line(x*sizeCellX, y*sizeCellY, (x + 1)*sizeCellX - 1, y*sizeCellY);
                    }
                    if (cells[x][y].hasLeftWall() && x == 0) {
                        line(x*sizeCellX, y*sizeCellY, x*sizeCellX, (y + 1)*sizeCellY - 1);
                    }
                    if (cells[x][y].hasBottomWall() && y == nbCellsY - 1) {
                        line(x*sizeCellX, (y + 1)*sizeCellY - 1, (x + 1)*sizeCellX - 1, (y + 1)*sizeCellY - 1);
                    }
                }
            }
        }
    }
}

