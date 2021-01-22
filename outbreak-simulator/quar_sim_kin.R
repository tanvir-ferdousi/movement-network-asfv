source("lib/Para_SEIR.R");
source("lib/Post_Population.R");
source("lib/GEMF_SIM.R");
source("lib/Net_Import2.R");
source("lib/Pop_Quantize.R");
source("lib/NeighborhoodDataWD.R");
source("lib/Net_Construct.R");
library("R.matlab")

graphDirectory = "../graph-generator/outputs/";

#Importing a directed and weighted Net from a file
pigEdgeListFile = paste(graphDirectory, "pigEdgeList.txt", sep="")
dum=Net_Import2(pigEdgeListFile,edgelist=TRUE,adjacencymatrix=FALSE);
#Net=dum[[1]];
N=dum[[2]];

# Read farm type data
File = paste(graphDirectory, "farmNodeList.txt", sep="")
farmType = scan(File);
NF = length(farmType)

File = paste(graphDirectory, "pigNodeList.txt", sep="")
dat = scan(File);
pigList=t(matrix(dat,2,N))

# Run quarantine simulation
# 1. For a particular isolation scheme, choose to isolate a certain number of farms
# 2. Remove all the between farm links from these farms
# 3. Run simulations and compute the epidemic size in each iteration.

# Selected number of farm on different schemes based on matching fraction of population
# BC: 5, 10, 18, 40
# KOUT: 5, 8, 16, 40
# KIN: 5, 18, 22, 51

scheme= "KOUT";    # Choose a scheme

File = paste("param/F_H_",scheme, ".txt", sep="");
FARM_LIST = scan(File);

IsolationLevels = c(1,2,5,7,10,15,20,30,40,50);

for(nFarmIsolate in IsolationLevels)
{
  targetFarms = FARM_LIST[1:nFarmIsolate];
  
  pigsEdgeList = scan(pigEdgeListFile);
  lL = length(pigsEdgeList);
  listIndex = seq(3,lL,3);
  L1=pigsEdgeList[listIndex-2];
  L2=pigsEdgeList[listIndex-1];
  L3=pigsEdgeList[listIndex];
  
  # Isolation
  totPigsIsolated = 0;
  edgeListRemInd = vector();
  for(farm in targetFarms)
  {
    pigs = which(pigList[,2] == farm)
    totPigsIsolated = totPigsIsolated + length(pigs);
    
  
    L1_match = which(L1 %in% pigs);
    L1_match_rem_ind = which(!(L2[L1_match] %in% pigs));
    L1_rem_ind = L1_match[L1_match_rem_ind];
    
    L2_match = which(L2 %in% pigs);
    L2_match_rem_ind = which(!(L1[L2_match] %in% pigs));
    L2_rem_ind = L2_match[L2_match_rem_ind];
    
    edgeListRemInd = union(union(L1_rem_ind,L2_rem_ind),edgeListRemInd);
  }
  edgeListRemInd = sort(edgeListRemInd);
  
  L1_new = L1[-edgeListRemInd];
  L2_new = L2[-edgeListRemInd];
  L3_new = L3[-edgeListRemInd];
  
  dum = Net_Construct(L1_new, L2_new, L3_new);
  Net=dum[[1]];
  N=dum[[2]];
  
  
  # Read simulation parameters (beta, I0, iters, Tend, maxEvents)
  sim_parameters = scan("param/sim_params.txt")
  bet = sim_parameters[1];
  I0 = sim_parameters[2];
  iter=sim_parameters[3];
  Runtime=sim_parameters[4];
  maxNumevent=sim_parameters[5];
  
  
  #setting up the SEIR epidemic model
  # Avg herd size = 1379
  # Min Beta = 0.00038188761 (0.7) and Max Beta = 0.00125499 (2.2) (using specific herd sizes)
  # in use 25% less beta = 0.00090908047(1.253925) and 25% more Beta = 0.001515134(2.089875)
  # Median Beta = 0.0012121212 (1.6719)
  #betaArray = c(0.00090908047, 0.0012121212, 0.001515134);
  #bet = betaArray[1];  #Weighted median from Guinat(2017)
  sig = 1/7.78;
  gam = 1/8.3;
  
  Para = Para_SEIR(bet,sig,gam);
  
  M<-Para[[1]];
  
  
  StateArray = array(0,c(iter,M,Runtime+1));
  
  for (i in 1:iter) {
    msg <- sprintf("Core 1, beta: %f, Iteration: %d",bet,i);
    print(msg);
    
    # Randomly select a farm
    inf_farm = sample(1:NF,1,replace=F);
    
    # Infect at most 10 pigs in that farm
    pigs = which(pigList[,2] == inf_farm);
    
    if(I0 > length(pigs))
    {
      toInfect = length(pigs);
    }
    else
    {
      toInfect = I0;
    }
    msg <- sprintf("Quarantined %d farms, infecting %d pigs in farm %d",nFarmIsolate,toInfect,inf_farm);
    print(msg);
    
    inf_nodes = sample(pigs,toInfect,replace=F);
    x0 = matrix(1,1,N);
    x0[inf_nodes] = 3;
    
    # simulating one realization of the epedimic process
    lst<-GEMF_SIM(Para,Net,x0,maxNumevent,Runtime,N);
    
    ts<-lst[[1]];
    n_index<-lst[[2]];
    i_index<-lst[[3]];
    j_index<-lst[[4]];
    Tf<-lst[[5]];
    lasteventnumber<-lst[[6]];
    
    lst2<-Post_Population(x0,M,N,ts,i_index,j_index,lasteventnumber);
    T<-lst2[[1]];
    StateCount<-lst2[[2]];
    
    # quantize the results (daywise)
    lst3<-Pop_Quantize(T,StateCount,Runtime);
    Tq<-lst3[[1]];
    StateCountq<-lst3[[2]];
    
    StateArray[i,,] = StateCountq
  };
  
  dataFileName <- sprintf("pig_sim_data_quar_%s_%d",scheme,nFarmIsolate);
  
  fileWithPath <- sprintf("outputs/quarantine/%s.mat", dataFileName)
  
  writeMat(fileWithPath,StateArray = StateArray, Tq = Tq)

}
