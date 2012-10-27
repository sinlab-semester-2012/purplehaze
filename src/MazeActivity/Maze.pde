
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
        
        currentCell[0] = 0;
        currentCell[1] = 0;
        
        while (generateExistsUnvisited(visitedCells)) {
            if (generateHasUnvisitedNeighbours(currentCell)) {
                neighbourCell = generatePickUnvisitedNeighbour(currentCell);
                cellStack.push(currentCell);
                
                boolean verticWall = (currentCell[0] != neighbourCell[0] && currentCell[1] == neighbourCell[1]);
                boolean horizWall = (currentCell[1] != neighbourCell[1] && currentCell[0] == neighbourCell[0]);
                int wallStartX, wallStartY, wallEndX, wallEndY;
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
                
                currentCell = neighbourCell;
                visitedCells(currentCell[0], currentCell[1]) = true;
            } else if (!cellStack.isEmpty()) {
                currentCell = cellStack.pop();
            } else {
                currentCell = generatePickRandomUnvisited();
                visitedCells(currentCell[0], currentCell[1]) = true;
            }
        }
    }
    
    // used only in generate(): check if there are unvisited cells
    void generateExistsUnvisited(Boolean[][] visitedCells) {
        for (int x = 0; x < visitedCells.length; x++) {
            for (int y = 0; y < visitedCells[0].length; y++) {
                if (!visitedCells[x][y]) {
                    return true;
                }
            }
        }
        return false;
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

