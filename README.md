Interactive Walls: Dynamic Light Projection through Fog
==================================
(code name: purplehaze)

by Michael Chablais



Description
===========

Master Semester Project, SINLAB/LDM, EPFL.

The aim of this project is to experiment with the concept of walls and how 
people act in their presence. Using technological advancements such as those 
that are offered by Computer Science, how can we literally as well as 
metaphorically transform and reconstruct walls? By having dynamic walls that 
react to user presence, we try to create a new type of interaction with 
architectural structures.

Projecting light through fog is one interesting way to play with the concept 
of barriers and frontiers. Using a camera, a projector and theatrical fog, we 
will reflect on new kinds of human-wall interaction, as well as on their 
meanings and implications. We will hope to do so through three main activities, 
each exploring different aspects of structure interaction: the taming of a 
dynamic Bézier curve (collaborative task), a playful maze escape (individual 
task), and a lighthearted fight based on halos of light (confrontative task).



Contents
========

- doc: extra documentation
- src: application code

See the Wiki page for more details about the code.



Setup and Dependencies
======================

- Processing 1.5.1 (http://processing.org/)
- OpenCV 2.3.1 (http://sourceforge.net/projects/opencvlibrary/)
- javacvPro (http://www.mon-club-elec.fr/pmwiki_reference_lib_javacvPro/pmwiki.php)
- GSVideo (http://gsvideo.sourceforge.net/)



Instructions
============

Each activity has a dedicated folder. In each folder, you will find the main 
Processing sketch to run (the one with the same name as the folder) and 
additional useful source files.

BezierWall
----------------

Setup and run:
- Run BezierWall.pde
- Point the camera to a blank (uniform) floor, and press the space bar once.
- The Bézier wall will appear and move.
- Step in front of the camera and interact with the curve.

Keyboard controls:
- Space Bar = capture current frame as reference image for blob detection
- Enter/Return Key = randomly generate another curve
- - = decrease the number of position points
- + = increase the number of position points
- . = toggles Bézier curve debugging display 
- / = toggles OpenCV debugging display 
- * = toggles blob detection debugging display 

MazeActivity
----------------

Setup and run:
- Run MazeActivity.pde
- Point the camera to a blank (uniform) floor, and press the space bar once. 
- Two green panels will appear. These are the two entrances of the maze. 
You have to enter the maze by one of them.
- Once you're inside the maze, you will have to get out by going through 
the other green "door". You cannot see every wall of the maze, only those 
that are near you.
- If you get out, you win. If you touch a wall, you lose.

Keyboard controls:
- Space Bar = capture current frame as reference image for blob detection
- * = toggles blob detection debugging display 

FightingHalosActivity
----------------

Setup and run:
- Run FightingHalosActivity.pde
- Point the camera to a blank (uniform) floor, and press the space bar once.
- Interact.

Keyboard controls:
- Space Bar = capture current frame as reference image for blob detection
- / = toggles OpenCV debugging display 
- * = toggles blob detection debugging display 



Development Status
==================

Week 12:
- Code maintenance on first two activities (Bézier & maze).
- Begun working on third activity (halos).

To Do / Issues
--------------
- Add more interaction to the Bézier wall.
- Add coins to collect and pursuing monster to the maze escape.
- Refine third task.

Previous Prototyping Steps
------------------------

Week 1:
- First meeting with Alex, discussion of starting point.

Week 2:
- Presented 10 brainstormed ideas:
https://docs.google.com/drawings/d/1Bdf2ic_uqQch1j4MZ-t4-P2q23K1SHFOxOTZ_wEGIK4/edit
  
Week 3:
- Decided on which idea to focus on (dynamic light projection through fog).
- Environment setup (Processing, OpenCV).
- First very simple graphic prototype of Bézier curve/wall.
  
Weeks 4-5:
- Final working environment setup (correct versions of Processing, OpenCV, 
javacvPro).
- Blob detection working, simple method (absdiff with ref image and threshold).
- Dynamic Bézier wall working, as well as interaction with said blobs (position 
points of curve avoid arriving blobs centroids).

Week 6:
- Finished first working version of the dynamic Bézier wall.

Week 7:
- First version of dynamic Bézier curve/wall fully working 
- Additional refinements on dynamic Bézier curve/wall (adding debugging display,
preparing for some refactoring, working on enhanced interaction)
- Working on the second idea, the maze escape (currently on maze generation step).

Week 8:
- Mid-semester presentation
- Working on enhancing interaction in Bézier curve activity.
- Working on the second idea, the maze escape (currently on maze generation step).

Week 10:
- Finished first working version of the maze escape.

--------------------------------------------------------------------------------