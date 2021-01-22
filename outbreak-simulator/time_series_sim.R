source("lib/NeighborhoodDataWD.R");
source("lib/Para_SEIR.R");
source("lib/Post_Population.R");
source("lib/GEMF_SIM.R");
source("lib/Net_Import2.R");
source("lib/Pop_Quantize.R")
library("R.matlab")

graphDirectory = "../graph-generator/outputs/";

#Importing a directed and weighted Net from a file
File = paste(graphDirectory, "pigEdgeList.txt", sep="")
dum=Net_Import2(File,edgelist=TRUE,adjacencymatrix=FALSE);
Net=dum[[1]];
N=dum[[2]];

# Read farm type data
File = paste(graphDirectory, "farmNodeList.txt", sep="")
farmType = scan(File);
NF = length(farmType)

File = paste(graphDirectory, "pigNodeList.txt", sep="")
dat = scan(File);
pigList=t(matrix(dat,2,N))



#setting up the SEIR epidemic model
# Avg herd size = 1379
# Min Beta = 0.00038188761 (0.7) and Max Beta = 0.00125499 (2.2) (using specific herd sizes)
# 25% less beta = 0.00090908047(1.253925) and 25% more Beta = 0.001515134(2.089875)
# Median Beta = 0.0012121212 (1.6719)
bet = 0.0012121212;  #Weighted median from Guinat(2017)
sig = 1/7.78;
gam = 1/8.3;

# initial condition
I0 = 10;

# simulation terminator 
maxNumevent=180000;Runtime=300;iter=25;



# Prepare data
Para = Para_SEIR(bet,sig,gam);
M<-Para[[1]];

StateArray = array(0,c(iter,M,Runtime+1));


# Run the simulation
for (i in 1:iter) {
  iterNoMsg <- sprintf("Iteration: %d: ",i);
  
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
  
  iterDesMsg <- sprintf("Infecting %d pigs in farm %d",toInfect,inf_farm);
  print(paste(iterNoMsg, iterDesMsg, sep=""));
  
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

writeMat("outputs/time_series/asfv_sim_data.mat",StateArray = StateArray, Tq = Tq)
