% Here goes your heading

int: W = 0; % white (empty) cells
int: B = -1; % black (forbidden) cells

% Definition of the problem
int: rows;
%set of 1..rows: ROW;
int: cols;
%set of var 1..cols: COL;
array[1..rows, 1..cols] of int: problem;

% Length of the loop
int: max_steps;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
array[1..max_steps] of var 1..rows: rowVals;    %% Array to store the row indexes of the squares visited.
array[1..max_steps] of var 1..cols: colVals;    %% Array to store the col indexes of the squares visited.
int: maxPoints = max([problem[i,j] | i in 1..rows, j in 1..cols]);  
array[1..max_steps] of var 0..maxPoints: values;  %% Array to store the values of the squares visited.
var int: total = sum(values);                   %% Variable is declared as we're using it to maximize and print it. 

%% Make sure that the start and end boxes are just a step apart.
%% Sum of difference makes sure we do not move in diagonals and move just 1 step at a time.
constraint ((abs(rowVals[max_steps] - rowVals[1]) + abs(colVals[max_steps] - colVals[1])) = 1);

%% Make sure the square we visit is not blocked/forbidden.
constraint forall(i in 1..max_steps)(values[i] = problem[rowVals[i],colVals[i]] /\ problem[rowVals[i],colVals[i]] != B);

%% Make sure that we do not revisit the square. 
constraint forall(i,j in 1..max_steps where i<j)(rowVals[i] != rowVals[j] \/ colVals[i] != colVals[j]);

%% Make sure that we do not move in diagonals and 1 step at a time.
constraint forall(i in 1..max_steps-1) ((abs(rowVals[i] - rowVals[i+1]) + abs(colVals[i] - colVals[i+1])) = 1);

%% As we're allowed to start the path from any co-ordinate, the same path can be obtained from any coordinate causing path symmetry.
%% Removing the path symmetry. Making sure the start point is always the lowest co-ordinates. 
%% Multiplying rowVals with a constant removes the same sum scenario when x and y values are reversed.
constraint forall(i in 2..max_steps)(rowVals[1]*cols*rows+colVals[1] < rowVals[i]*cols*rows+colVals[i]);


%% Directional symmetry is when we start from a point n go clock-wise or counter clockwise. 
%%Here it says, move clock-wise. If multiply the constant with y axis, it says move anti-clockwise.
constraint (rowVals[1] = rowVals[2]);  
constraint forall (i in 3..max_steps) (rowVals[2]*cols*rows+colVals[2]  < rowVals[i]*cols*rows+colVals[i] );  

%% Anti-clockwise
%% constraint (colVals[1]=colVals[2]);  

solve maximize total;
output [" x     : \(rowVals)\n y     : \(colVals)\n values: \(values)\n total : \(total)\n"] ;
