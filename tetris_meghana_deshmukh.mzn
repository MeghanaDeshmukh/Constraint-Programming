% Here goes your heading
include "globals.mzn";
include "geost.mzn";


%Number of blocks
int: n = 7;
set of int: BLOCK = 1..n;
%Number of rectangle/offsets
int: m = 23;
set of int: ROFF = 1..m;
%Definitions of rectangles
%First and second column represent offsets
%Third and fourth column represent sizes
array[ROFF,1..4] of int: d =
[|0,0,3,1
 |1,1,1,1
 |0,0,1,3
 |0,1,3,1
 |1,0,1,1
 |0,1,1,1
 |1,0,1,3
 |0,0,4,1
 |0,0,1,4
 |0,0,2,2
 |1,2,1,1
 |2,0,1,1
 |0,0,1,1
 |2,1,1,1
 |0,2,1,1
 |0,0,2,1
 |1,1,2,1
 |0,1,1,2
 |1,0,1,2
 |0,1,2,1
 |1,0,2,1
 |0,0,1,2
 |1,1,1,2|];

%Possible shapes and their rotated forms
array[int] of set of ROFF: shape =
[{1,2},   %Block 1
 {2,3},   %Block 1 - r270
 {4,5},   %Block 1 - r180
 {6,7},   %Block 1 - r90
 {8},     %Block 2
 {9},     %Block 2 - r90
 {10},    %Block 3
 {1,6},   %Block 4
 {3,11},  %Block 4 - r270
 {4,12},  %Block 4 - r180
 {7,13},  %Block 4 - r90
 {1,14},  %Block 5
 {3,5},   %Block 5 - r270
 {4,13},  %Block 5 - r180
 {7,15},  %Block 5 - r90
 {16,17}, %Block 6
 {18,19}, %Block 6 - r90
 {20,21}, %Block 7
 {22,23}];%Block 7 - r90

%Possible rotations of blocks
enum ROTATE = {R0, R90, R180, R270};

%Number of blocks of each type
array[BLOCK] of int: number_blocks;

%Width of the puzzle
int: width;


%%%% Constraints to solve the problem %%%%%%%%
array[BLOCK] of set of int: index = 
[{1,4,3,2},
{5,6},
{7},
{8,11,10,9},
{12,15,14,13},
{16,17},
{18,19}];

%number_blocks = [0,1,2,3,1,1,1]; data 2
set of int: SHAPE = index_set(shape);  
array[SHAPE] of int: rotation = [1,4,3,2, 1,2, 1, 1,4,3,2, 1,4,3,2, 1,2, 1,2];

int: maxHeight = 8; 
var 6..maxHeight: height;  

int: totalBlocks = sum(i in BLOCK)(number_blocks[i]);     %% Get the total blocks we need to fit.
array[1..totalBlocks] of var 0..width: x;                 %% The array of all blocks with value being the x-position in final grid.
array[1..totalBlocks] of var 0..maxHeight: y;             %% The array of all blocks with value being the y-position in final grid.

%% Geost
set of int: DIM = 1..2;
array[ROFF,DIM] of int: rect_size = 
     array2d(ROFF,DIM, [ d[r,i] | r in ROFF, i in 3..4]);
array[ROFF,DIM] of int: rect_offset = 
     array2d(ROFF,DIM, [ d[r,i] | r in ROFF, i in 1..2]);    
   
array[1..totalBlocks] of var SHAPE: kind;
array[1..totalBlocks,DIM] of var int: coords =
      array2d(1..totalBlocks,DIM, [ if j = 1 then x[i] else y[i] endif
                         | i in 1..totalBlocks, j in 1..2 ]);

constraint geost_bb(2, rect_size, rect_offset, shape, coords, kind, [0,0], [width,height]);
constraint forall (i in BLOCK) 
( among(number_blocks[i], kind, index[i]) );

solve minimize height;
output [" shapes: \(kind)\n co-ordinates: \(coords)\n height:\(height)\n"];
output [ "-- "
  ++ "(\(i)) : Shape:\(kind[i]) \(coords[i,1]), \(coords[i,2]) \(ROTATE[rotation[kind[i]]])\n" | i in 1..totalBlocks  ];

%%%%%%%% End %%%%%%%%%%%%%%