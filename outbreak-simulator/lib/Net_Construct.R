Net_Construct<-function(L1,L2,L3){
  N=max(c(max(L1),max(L2)));
  
  ft=NeighborhoodDataWD(N,L1,L2,L3);
  I1=matrix(ft[[2]],1,N);
  I2=matrix(ft[[3]],1,N);
  list(list(ft[1],I1,I2),N);
}

