
class Maze {
    
    final float EDGE_WIDTH = 0.0075*(width + height);
    
    int nbCellsX;
    int nbCellsY;
    float sizeCellX;
    float sizeCellY;
    // a wall is represented by a start point and an end point (both set to true)
    boolean[][] walls;
    
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
        walls = new boolean[nbCellsX + 1][nbCellsY + 1];
        for (int x = 0; x < nbCellsX + 1; x++) {
            for (int y = 0; y < nbCellsY + 1; y++) {
                walls[x][y] = true;
            }
        }
    }
    
    // generate maze using backtracking depth-first search algorithm
    // (http://en.wikipedia.org/wiki/Maze_generation_algorithm#Recursive_backtracker)
    void generate() {
        Integer[] currentCell = new Integer[2];
        Integer[] neighbourCell = new Integer[2];
        Boolean[][] visitedCells = new Boolean[nbCellsX][nbCellsY];
        for (int x = 0; x < visitedCells.length; x++) {
            for (int y = 0; y < visitedCells[0].length; y++) {
                visitedCells[x][y] = false;
            }
        }
        Deque<Integer[]> cellStack = new ArrayDeque<Integer[]>();
        
        // 1. make initial cell the current cell and mark it as visited
        currentCell[0] = 0;
        currentCell[1] = 0;
        visitedCells[currentCell[0]][currentCell[1]] = true;
        
        // 2. while there are unvisited cells
        while (generateExistsUnvisited(visitedCells)) {
            // a. if current cell has any neighbours which have not been visited 
            if (generateHasUnvisitedNeighbours(visitedCells, currentCell)) {
                // i. choose randomly one of the unvisited neighbours
                neighbourCell = generatePickUnvisitedNeighbour(visitedCells, currentCell);
                // ii. push current cell to stack
                cellStack.push(currentCell);
                // iii. remove wall between current cell and chosen cell
                boolean verticWall = (currentCell[0] != neighbourCell[0] && currentCell[1] == neighbourCell[1]);
                boolean horizWall = (currentCell[1] != neighbourCell[1] && currentCell[0] == neighbourCell[0]);
                int wallStartX = 0, wallStartY = 0, wallEndX = 0, wallEndY = 0;
                if (verticWall) {
                    wallStartX = max(currentCell[0], neighbourCell[0]);
                    wallStartY = currentCell[1];
                    wallEndX = wallStartX;
                    wallEndY = wallStartY + 1;
                } else if (horizWall) {
                    wallStartX = currentCell[0];
                    wallStartY = max(currentCell[1], neighbourCell[1]);
                    wallEndX = wallStartX + 1;
                    wallEndY = wallStartY;
                }
                walls[wallStartX][wallStartY] = false;
                walls[wallEndX][wallEndY] = false;
                // iv. make chosen cell the current cell and mark it as visited
                currentCell = neighbourCell;
                visitedCells[currentCell[0]][currentCell[1]] = true;
            // b. else if stack is not empty 
            } else if (!cellStack.isEmpty()) {
                // i. pop cell from the stack, make it the current cell
                currentCell = cellStack.pop();
            // c. else
            } else {
                // i. pick random cell, make it the current cell and mark it as visited
                currentCell = generatePickRandomUnvisited(visitedCells);
                visitedCells[currentCell[0]][currentCell[1]] = true;
            }
        }
    }
    
    // used only in generate(): check whether there are unvisited cells
    boolean generateExistsUnvisited(Boolean[][] visitedCells) {
        for (int x = 0; x < nbCellsX; x++) {
            for (int y = 0; y < nbCellsY; y++) {
                if (!visitedCells[x][y]) {
                    return true;
                }
            }
        }
        return false;
    }
    
    // used only in generate(): check whether cell has unvisited neighbours
    boolean generateHasUnvisitedNeighbours(Boolean[][] visitedCells, Integer[] cell) {
        int x = cell[0];
        int y = cell[1];
        if (x == 0) {
            if (y == 0) {
                return (!visitedCells[x + 1][y] || !visitedCells[x][y + 1]);
            } else if (y == nbCellsY - 1) {
                return (!visitedCells[x + 1][y] || !visitedCells[x][y - 1]);
            } else {
                return (!visitedCells[x + 1][y] || !visitedCells[x][y + 1] || !visitedCells[x][y - 1]);
            }
        } else if (x == nbCellsX - 1) {
            if (y == 0) {
                return (!visitedCells[x - 1][y] || !visitedCells[x][y + 1]);
            } else if (y == nbCellsY - 1) {
                return (!visitedCells[x - 1][y] || !visitedCells[x][y - 1]);
            } else {
                return (!visitedCells[x - 1][y] || !visitedCells[x][y + 1] || !visitedCells[x][y - 1]);
            }
        } else {
            return (!visitedCells[x + 1][y] || !visitedCells[x - 1][y] || !visitedCells[x][y + 1] || !visitedCells[x][y - 1]);
        }
    }
    
    // used only in generate(): pick random unvisited neighbour from cell
    Integer[] generatePickUnvisitedNeighbour(Boolean[][] visitedCells, Integer[] cell) {
        Integer[][] unvisitedNeighbourCells = new Integer[4][2];
        int count = 0;
        Integer[] neighbourCell = new Integer[2];
        
        int x = cell[0];
        int y = cell[1];
        if (x == 0) {
            if (y == 0) {
                if (!visitedCells[x + 1][y]) {
                   unvisitedNeighbourCells[count][0] = x + 1;
                   unvisitedNeighbourCells[count][0] = y;
                   count++;
                } 
                if (!visitedCells[x][y + 1]) {
                   unvisitedNeighbourCells[count][0] = x;
                   unvisitedNeighbourCells[count][0] = y + 1;
                   count++;
                }
            } else if (y == nbCellsY - 1) {
                if (!visitedCells[x + 1][y]) {
                   unvisitedNeighbourCells[count][0] = x + 1;
                   unvisitedNeighbourCells[count][0] = y;
                   count++;
                } 
                if (!visitedCells[x][y - 1]) {
                   unvisitedNeighbourCells[count][0] = x;
                   unvisitedNeighbourCells[count][0] = y - 1;
                   count++;
                }
            } else {
                if (!visitedCells[x + 1][y]) {
                   unvisitedNeighbourCells[count][0] = x + 1;
                   unvisitedNeighbourCells[count][0] = y;
                   count++;
                } 
                if (!visitedCells[x][y + 1]) {
                   unvisitedNeighbourCells[count][0] = x;
                   unvisitedNeighbourCells[count][0] = y + 1;
                   count++;
                }
                if (!visitedCells[x][y - 1]) {
                   unvisitedNeighbourCells[count][0] = x;
                   unvisitedNeighbourCells[count][0] = y - 1;
                   count++;
                }
            }
        } else if (x == nbCellsX - 1) {
            if (y == 0) {
                if (!visitedCells[x - 1][y]) {
                   unvisitedNeighbourCells[count][0] = x - 1;
                   unvisitedNeighbourCells[count][0] = y;
                   count++;
                } 
                if (!visitedCells[x][y + 1]) {
                   unvisitedNeighbourCells[count][0] = x;
                   unvisitedNeighbourCells[count][0] = y + 1;
                   count++;
                }
            } else if (y == nbCellsY - 1) {
                if (!visitedCells[x - 1][y]) {
                   unvisitedNeighbourCells[count][0] = x - 1;
                   unvisitedNeighbourCells[count][0] = y;
                   count++;
                } 
                if (!visitedCells[x][y - 1]) {
                   unvisitedNeighbourCells[count][0] = x;
                   unvisitedNeighbourCells[count][0] = y - 1;
                   count++;
                }
            } else {
                if (!visitedCells[x - 1][y]) {
                   unvisitedNeighbourCells[count][0] = x - 1;
                   unvisitedNeighbourCells[count][0] = y;
                   count++;
                } 
                if (!visitedCells[x][y + 1]) {
                   unvisitedNeighbourCells[count][0] = x;
                   unvisitedNeighbourCells[count][0] = y + 1;
                   count++;
                }
                if (!visitedCells[x][y - 1]) {
                   unvisitedNeighbourCells[count][0] = x;
                   unvisitedNeighbourCells[count][0] = y - 1;
                   count++;
                }
            }
        } else {
            if (!visitedCells[x + 1][y]) {
               unvisitedNeighbourCells[count][0] = x + 1;
               unvisitedNeighbourCells[count][0] = y;
               count++;
            } 
            if (!visitedCells[x - 1][y]) {
               unvisitedNeighbourCells[count][0] = x - 1;
               unvisitedNeighbourCells[count][0] = y;
               count++;
            } 
            if (!visitedCells[x][y + 1]) {
               unvisitedNeighbourCells[count][0] = x;
               unvisitedNeighbourCells[count][0] = y + 1;
               count++;
            }
            if (!visitedCells[x][y - 1]) {
               unvisitedNeighbourCells[count][0] = x;
               unvisitedNeighbourCells[count][0] = y - 1;
               count++;
            }
        }
        
        int r = floor(random(0, count));
        neighbourCell[0] = unvisitedNeighbourCells[r][0];
        neighbourCell[1] = unvisitedNeighbourCells[r][1];
        return neighbourCell;
    }
    
    // used only in generate(): pick random unvisited cell
    Integer[] generatePickRandomUnvisited(Boolean[][] visitedCells) {
        Integer[][] unvisitedCells = new Integer[nbCellsX*nbCellsY][2];
        Integer[] unvisitedCell = new Integer[2];
        int count = 0;
        
        for (int x = 0; x < nbCellsX; x++) {
            for (int y = 0; y < nbCellsY; y++) {
                if (!visitedCells[x][y]) {
                    unvisitedCells[count][0] = x;
                    unvisitedCells[count][1] = y;
                    count++;
                }
            }
        }
        
        int r = floor(random(0, count));
        unvisitedCell[0] = unvisitedCells[r][0];
        unvisitedCell[1] = unvisitedCells[r][1];
        return unvisitedCell;
    }
    
    // draw maze and maze objects
    void draw() {
        drawWalls();
    }
    
    // draw walls of maze
    void drawWalls() {
        stroke(255);
        strokeWeight(EDGE_WIDTH);
        strokeCap(ROUND);
        for (int x = 0; x < nbCellsX + 1; x++) {
            for (int y = 0; y < nbCellsY; y++) {
                if (walls[x][y] && walls[x][y + 1]) {
                    line(x*sizeCellX, y*sizeCellY, x*sizeCellX, (y + 1)*sizeCellY - 1);
                }
            }
        }
        for (int y = 0; y < nbCellsY + 1; y++) {
            for (int x = 0; x < nbCellsX; x++) {
                if (walls[x][y] && walls[x + 1][y]) {
                    line(x*sizeCellX, y*sizeCellY, (x + 1)*sizeCellX - 1, y*sizeCellY);
                }
            }
        }
    }
}

