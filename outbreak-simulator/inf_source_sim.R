setwd("G:/Cloud/Google Drive/KSU/Research/Projects/NBAF/Code/GEMF in R/homSim/Core 1")
source("../Para_SEIR.R");
source("../Post_Population.R");
source("../GEMF_SIM.R");
source("../Net_Import2.R");
source("../Pop_Quantize.R");
source("../NeighborhoodDataWD.R");
source("../Net_Construct.R");
library("R.matlab")

#Importing a directed and weighted Net from a file
pigNetwork = "../../network/pigsEdgeList.txt"
dum=Net_Import2(pigNetwork,edgelist=TRUE,adjacencymatrix=FALSE);
Net=dum[[1]];
N=dum[[2]];

# Read farm type data
File2 = "../../network/farmNodeList.txt"
farmType = scan(File2);
NF = length(farmType)

File3 = "../../network/pigsNodeList.txt"
dat = scan(File3);
pigList=t(matrix(dat,2,N))


# Run infection source analysis
# 1. Select a particular farm type
# 2. Infect a farm randomly from that farm type
# 3. Run simulations and compute the epidemic size in each iteration

# Read simulation parameters (beta, I0, iters, Tend, maxEvents)
sim_parameters = scan("../sim_params.txt")
bet = sim_parameters[1];
I0 = sim_parameters[2];
iter=sim_parameters[3];
Runtime=sim_parameters[4];
maxNumevent=sim_parameters[5];


#setting up the SEIR epidemic model
# Avg herd size = 1379
# in use 25% less beta = 0.00090908047(1.253925) and 25% more Beta = 0.001515134(2.089875)
# Median Beta = 0.0012121212 (1.6719)
#betaArray = c(0.00090908047, 0.0012121212, 0.001515134);
#bet = betaArray[1];  #Weighted median from Guinat(2017)
sig = 1/7.78;
gam = 1/8.3;

Para = Para_SEIR(bet,sig,gam);

M<-Para[[1]];

# Boar Stud, Farrow, Finisher, Market, Nursery
InfSources = 1:2;

for(infSrc in InfSources)
{
  StateArray = array(0,c(iter,M,Runtime+1));
  
  for (i in 1:iter) {
    msg <- sprintf("Core 1, beta: %f, Iteration: %d",bet,i);
    print(msg);
    
    # Select all farms from a given type
    farms_selected = which(farmType == infSrc);
    inf_farm = sample(farms_selected,1,replace=F);
    
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
    msg <- sprintf("Infecting %d pigs in farm %d of type %d",toInfect,inf_farm,infSrc);
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
  
  dataFileName <- sprintf("pig_sim_data_infsrc_%d",infSrc);
  
  fileWithPath <- sprintf("../results/infsrc/%s.mat", dataFileName)
  
  writeMat(fileWithPath,StateArray = StateArray, Tq = Tq)

}
