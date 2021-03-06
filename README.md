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
want to reflect on new kinds of human-wall interaction, as well as on their 
meanings and implications. We try to do so through three main activities, 
each exploring different aspects of structure interaction: the taming of a 
dynamic B�zier curve (collaborative task), a playful maze escape (individual 
task), and a lighthearted fight based on halos of light (confrontative task),
with a major focus on the first one.

You might be interested in the following presentation videos:
- Mid-semester presentation: http://www.youtube.com/watch?v=iN0YAy5bFpE
- End-semester presentation: http://www.youtube.com/watch?v=4D_Fkj3j8Y4
- Final Presentation: https://vimeo.com/57351424


Contents
========

- src: application code
- README.md: this readme file

See the Wiki page for more details about the code.



Setup and Dependencies
======================

- Processing 1.5.1 (http://processing.org/)
- OpenCV 2.3.1 (http://sourceforge.net/projects/opencvlibrary/)
- javacvPro 0.5 (http://www.mon-club-elec.fr/pmwiki_reference_lib_javacvPro/pmwiki.php)
- GSVideo 1.0.0 (http://gsvideo.sourceforge.net/)
- Ess r2 (http://www.tree-axis.com/Ess/)

Note that this was programmed and tested on a Windows 7 computer.

Instructions
============

The activities are meant to be experimented in a smoke-filled room. They 
should be run on computer connected to a projector (attached to the ceiling 
and pointed towards the ground) and a webcam (capturing the scene, also from 
above). The projector and the camera should ideally cover the same area.

Each activity has a dedicated folder. In each folder, you will find the main 
Processing sketch to run (the one with the same name as the folder) and 
additional useful source files.

BezierWallActivity
----------------

Setup and run:
- Run BezierWall.pde
- Point the camera to a blank (uniform) floor, and press the space bar once.
- The B�zier wall will appear and move.
- Step in front of the camera and interact with the wall. It will try to 
avoid participants and pulsate more and more as they approach. This will 
also be reflected through sound. Each participant will be represented as
a sine wave, and the wall as pink noise. The volume of each audio component 
will change as participants come near the wall.

Keyboard controls:
- Space Bar = capture current frame as reference image for blob detection
- Enter/Return Key = randomly generate another curve
- 0 = toggles fixation of endpoints (if on, endpoints stay the same when 
regenerating curve or changing number of position points)
- - = decrease the number of position points
- + = increase the number of position points
- . = toggles B�zier curve debugging display 
- / = toggles OpenCV debugging display 
- * = toggles blob detection debugging display 

MazeActivity (Unfinished)
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

FightingHalosActivity (Unfinished, Code Skeleton)
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

My contribution to this project is now over, but anyone interested in 
continuing or building on my work is encouraged to do so and contact 
SINLAB (http://www.sinlab.ch/) about it.

History
------------------------

Week 1:
- First meeting with Alex, discussion of starting point.

Week 2:
- Presented 10 brainstormed ideas:
https://docs.google.com/drawings/d/1Bdf2ic_uqQch1j4MZ-t4-P2q23K1SHFOxOTZ_wEGIK4/edit
  
Week 3:
- Decided on which idea to focus on (dynamic light projection through fog).
- Environment setup (Processing, OpenCV).
- First very simple graphic prototype of B�zier curve/wall.
  
Weeks 4-5:
- Final working environment setup (correct versions of Processing, OpenCV, 
javacvPro).
- Blob detection working, simple method (absdiff with ref image and threshold).
- Dynamic B�zier wall working, as well as interaction with said blobs (position 
points of curve avoid arriving blobs centroids).

Week 6:
- Finished first working version of the dynamic B�zier wall.

Week 7:
- First version of dynamic B�zier curve/wall fully working .
- Additional refinements on dynamic B�zier curve/wall (adding debugging display,
preparing for some refactoring, working on enhanced interaction).
- Working on the second idea, the maze escape (currently on maze generation step).

Week 8:
- Mid-semester presentation (http://www.youtube.com/watch?v=iN0YAy5bFpE).
- Working on enhancing interaction in B�zier curve activity.
- Working on the second idea, the maze escape (currently on maze generation step).

Week 10:
- Finished first working version of the maze escape.

Week 12:
- Code maintenance on first two activities (B�zier & maze).
- Begun working on third activity (halos).
- End-semester presentation (http://www.youtube.com/watch?v=4D_Fkj3j8Y4).

Week 14:
- Focus now only on B�zier Wall activity (improve interactivity).

Week 17:
- Improved B�zier Wall visual interactivity, and added an audio component to it.
- This concludes the final version of the code.
- Final presentation (https://vimeo.com/57351424).

--------------------------------------------------------------------------------