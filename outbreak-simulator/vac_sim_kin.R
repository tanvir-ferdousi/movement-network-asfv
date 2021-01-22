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
Net=dum[[1]];
N=dum[[2]];

# Read farm type data
File = paste(graphDirectory, "farmNodeList.txt", sep="")
farmType = scan(File);
NF = length(farmType)

File = paste(graphDirectory, "pigNodeList.txt", sep="")
dat = scan(File);
pigList=t(matrix(dat,2,N))

# Run vaccination simulation
# 1. For a particular vaccination scheme, choose to vaccinate 1, 2, 5, 7, 10, 15, 20, 30, 40, 50 farms
# 2. Vaccinate all pigs in those farms
# 3. Run simulations and compute the epidemic size in each iteration.

scheme= "KOUT";    # Choose a scheme
File = paste("param/F_H_",scheme, ".txt", sep="");
SORTED_FARMS = scan(File);


vac_eff = 0.8;

VaccinationLevels = c(1,2,5,7,10,15,20,30,40,50);



for(nFarmVaccinate in VaccinationLevels)
{
  
  x0 = matrix(1,1,N);
  targetFarms = SORTED_FARMS[1:nFarmVaccinate];

  
  # Vaccination
  totPigsImmune = 0;
  
  for(farm in targetFarms)
  {
    pigs = which(pigList[,2] == farm);
    vac_count = round(length(pigs)*vac_eff);
    immune_nodes = sample(pigs,vac_count,replace = F);
    x0[immune_nodes] = 4;
    totPigsImmune = totPigsImmune + vac_count;
  }
  
  
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
    y0 = x0;
    msg <- sprintf("Core 1, beta: %f, Iteration: %d",bet,i);
    print(msg);
    
    pigs = integer();
    
    while(length(pigs) < 1)
    {
      # Randomly select a farm
      inf_farm = sample(1:NF,1,replace=F);
      
      # Infect at most 10 pigs in that farm
      pigs = which(pigList[,2] == inf_farm);
      
      immunePigs = which(y0 == 4);
      pigs = setdiff(pigs,immunePigs);  # pigs that are immune can't be infected
    }
    
    if(I0 > length(pigs))
    {
      toInfect = length(pigs);
    }
    else
    {
      toInfect = I0;
    }
    msg <- sprintf("Vaccinated %d farms based on %s, infecting %d pigs in farm %d",nFarmVaccinate, scheme,toInfect,inf_farm);
    print(msg);
    
    inf_nodes = sample(pigs,toInfect,replace=F);
    
    y0[inf_nodes] = 3;
    
    # if(length(pigs) > 0)
    # {
    # }
    # else{
    #   msg <- sprintf("Vaccinated %d farms based on kin, no pigs susceptible to infect in farm %d",nFarmVaccinate, inf_farm);
    #   print(msg);
    # }
    
    # simulating one realization of the epedimic process
    lst<-GEMF_SIM(Para,Net,y0,maxNumevent,Runtime,N);
    
    ts<-lst[[1]];
    n_index<-lst[[2]];
    i_index<-lst[[3]];
    j_index<-lst[[4]];
    Tf<-lst[[5]];
    lasteventnumber<-lst[[6]];
    
    lst2<-Post_Population(y0,M,N,ts,i_index,j_index,lasteventnumber);
    T<-lst2[[1]];
    StateCount<-lst2[[2]];
    
    # quantize the results (daywise)
    lst3<-Pop_Quantize(T,StateCount,Runtime);
    Tq<-lst3[[1]];
    StateCountq<-lst3[[2]];
    
    StateCountq[4,] = StateCountq[4,] - StateCountq[4,1];
    
    StateArray[i,,] = StateCountq
  };
  
  
  dataFileName <- sprintf("pig_sim_data_vac_%s_%d",scheme,nFarmVaccinate);
  
  fileWithPath <- sprintf("outputs/vaccinate/%s.mat", dataFileName)
  
  writeMat(fileWithPath,StateArray = StateArray, Tq = Tq, totPigsImmune = totPigsImmune)

}
