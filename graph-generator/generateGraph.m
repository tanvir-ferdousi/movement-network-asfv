%% Parameters and data for 2 counties of Iowa
NF = 84;            % Number of farms
NP = 249150;        % Number of animals (pigs)

scaleFactor = 20;   % scale down the network by a factor
pWithinFarm = 0.5;            % animal interaction probability within farm

M = 5;              % Farm operation types

% No. of farms in each type: [Boar Stud, Farrow, Finishing, Market, Nursery]
M_COUNT = [3 64 123 17 30]'; 
M_PROB = M_COUNT/sum(M_COUNT);

% AVG Degrees for different types
%K_IN_AVG = [0.67 0.92 1.05 11.73 0.77]';
%K_OUT_AVG = [1 2.08 1.74 0.46 3.07]';

% directed association matrix
DA_MATRIX = [0 0 0 0.01 0; 0 0.03 0.09 0.10 0.04; 0.01 0.10 0.07 0.40 0; 0 0 0 0.02 0; 0 0 0.13 0 0];

% Shipments per year
meanShipments = 17.38;  % Avg of rice and stevens
medianShipments = 8.5;  % Avg of two medians

% farm and pig count for given data (2 counties)
% The 7 rows represent the population classes: 1-24, 25-49, 50-99, 100-199, 200-499,
% 500-999 and 1000+.
% Col 1: Number of farms in a class
% Col 2: Total number of pigs belonging to those farms in Col 1
PIG_STAT = [17 204;
            0 0; 
            0 0; 
            2 300; 
            3 700; 
            11 7904; 
            51 240042];

%% Step 1 A: Either generate a farm level graph
% Either one of Step 1 A or Step 1 B should be used, with the other one
% kept commented out
F_TYPE = FTypeGen(M_PROB,NF);
FARM_GRAPH = DAGraph(DA_MATRIX, NF, F_TYPE);

% Add weights to the farm level graph edges using shipments
FARM_GRAPH = movementGen(FARM_GRAPH, meanShipments, medianShipments);

saveFarmEdgeList('outputs/farmEdgeList.txt',FARM_GRAPH);
saveFarmNodeList('outputs/farmNodeList.txt',F_TYPE);
%% Step 1 B: Or load a previously generated one
FARM_EDGES = load('outputs/farmEdgeList.txt');
F_TYPE = load('outputs/farmNodeList.txt');
FARM_GRAPH = zeros(NF,NF);

for i=1:length(FARM_EDGES)
    fr = FARM_EDGES(i,1);
    to = FARM_EDGES(i,2);
    FARM_GRAPH(fr,to) = FARM_EDGES(i,3);
end
%% Step 2: Generate animal level graph
% Generate and allot pigs to farms based on data and apply scale factor
Pigs = pigGen(PIG_STAT);
scaledPigs = ceil(Pigs/scaleFactor);
SNP = sum(scaledPigs);                                  % Scaled number of pigs

N_FARM_GRAPH = FARM_GRAPH/max(max(FARM_GRAPH));         % Normalize the weights of movement network

% Network generation
pigEdgeList = pigNetworkGen(scaledPigs, N_FARM_GRAPH, pWithinFarm);

savePigsEdgeList('outputs/pigEdgeList.txt',pigEdgeList);
savePigsNodeList('outputs/pigNodeList.txt',scaledPigs);
%% Other data storage
%edgeList = edgeListGenDirected(FARM_GRAPH);

%saveGephiEdgeList('outputs/network/damGraphEdges.csv', pigEdgeList);
%saveGephiNodeList('outputs/network/damGraphNodes.csv', SNP);

%saveMiscData('../GEMF in R/network/miscData.txt',NF,SNP,NP);