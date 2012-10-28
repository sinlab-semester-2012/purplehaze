Interactive Walls: Dynamic Light Projection through Fog
==================================
(code name: purplehaze)

by Michael Chablais


Description
===========

Master Semester Project, SINLAB/LDM, EPFL.

The aim of this project is to experiment with the concept of walls and how 
people act in their presence. Using technological advancements such as those 
that are offered by Computer Science, how can we metaphorically transform and 
reconstruct walls? By having dynamic walls that react to user presence, we try 
to create a new type of interaction with architectural structures.

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


DynBezierCurveActivity
----------------

Setup and run:
- Run DynBezierCurveActivity.pde
- The Bézier curve will appear and move.
- Point the camera to a blank (uniform) wall or floor, and press the space bar once. 
- Step in front of the camera and interact with the curve.

Keyboard controls:
- Space Bar = capture current frame as reference image for blob detection
- Enter/Return Key = randomly generate another curve
- . = toggles debugging display 
- - = decrease the number of position points
- + = increase the number of position points
- * = toggles fixation of the first and last position points


Development Status
==================

Week 7:
- First version of dynamic Bézier curve/wall fully working (since Week 6).
- Working on the second idea, the maze escape (currently on maze generation step).

To Do / Issues
--------------
- Add more interaction to the Bézier wall. It is currently simply avoiding the user.
- Continue working on the maze.
- Refine third idea (halos interaction).
- Define clear goals for the end.

Previous protyping steps
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


--------------------------------------------------------------------------------