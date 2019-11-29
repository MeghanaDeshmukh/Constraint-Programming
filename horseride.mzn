% Your heading goes here
include "inverse.mzn";
include "global_cardinality.mzn";
include "alldifferent_except_0.mzn";

int: n; % number of guests
set of int: GUEST = 1..n;
int: president = 1;
array[GUEST] of int: rank;
array[GUEST] of int: ability;

int: m; % number of horses
set of int: HORSE = 1..m;
array[HORSE] of int: beauty;
array[HORSE] of int: speed;
array[GUEST,HORSE] of int: enjoy;

%%% Declare the horse array %%
array[GUEST] of var 0..m: goal;  %% 0..m to assign 0 for the guests with no horse. 
array[HORSE] of var bool: booked; 
array[HORSE] of var 0..n: assigned;
array[GUEST] of var bool: riders; 

%% Constraint to make sure that the president gets the max enjoyment.
%% To make sure NONE of the guests have more enjoyment than the president
constraint forall(i in GUEST where i!=1 /\ goal[i] !=0)
(enjoy[i,goal[i]] < enjoy[1,goal[1]]  /\ enjoy[i,goal[i]] > 0);

%% Should be different to satisfy the contraint where guests are more and horses are less. 
%constraint alldifferent_except_0(goal);  
%constraint alldifferent_except_0(assigned); 

%% To make sure all the horses are booked.
constraint 
(sum(i in GUEST)(booked[goal[i]]) = min(m,n));  %% m when m is smaller. n when n is smaller.
constraint 
(sum(i in HORSE)(riders[assigned[i]]) = min(m,n));  %% m when m is smaller. n when n is smaller.


%% constraint to make sure that higher rank guest gets the better beauty in horse.
constraint forall (i,j in GUEST where i!=j /\ (rank[i] > rank[j]))
(beauty[goal[i]] >= beauty[goal[j]] \/ goal[j]=0 \/ (goal[i]=0 /\ goal[j]=0));

%% constraint to make sure that the faster horse has the better ability rider. 
constraint forall (i,j in HORSE where i!=j /\ (speed[i] > speed[j]))
((ability[assigned[i]] >= ability[assigned[j]]) \/ assigned[i]=0 \/ (assigned[i]=0 /\ assigned[j]=0));

%% Map the assigned and goal arrays
constraint forall(i in GUEST where goal[i] != 0)
(i = assigned[goal[i]] );
constraint forall(i in HORSE where assigned[i] != 0)
(i = goal[assigned[i]] );

solve satisfy;
output["horse = \(goal)"]