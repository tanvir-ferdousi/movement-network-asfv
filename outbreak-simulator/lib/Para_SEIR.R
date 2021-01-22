Para_SEIR<-function(bet, sig, gam){
  M=4;  #number of compartments
  q=matrix(3,1,1);# matrix of influencer compartment for each layer which has the dimension of 1 by number of layers
  l=length(q);
  
  A_d=matrix(0,M,M);# node base transition matrix
  A_d[2,3]<-sig;
  A_d[3,4]<-gam;
  
  A_b=array(0,c(M,M,l));#edgebase transittion array for different layers
  A_b[1,2,1]<-bet;
  
  list(M,q,l,A_d,A_b);
}