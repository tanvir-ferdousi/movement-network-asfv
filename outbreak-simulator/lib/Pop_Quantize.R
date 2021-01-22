Pop_Quantize<-function(T,StateCount,Runtime){
  Tq = 0:Runtime;
  StateCountq = array(0,c(nrow(StateCount),Runtime+1));
  
  StateCountq[,1] = StateCount[,1];
  
  for (i in 1:Runtime) {
    qInd = tail(which(T<=i),1);
    StateCountq[,(i+1)] = StateCount[,qInd];
  };
  
  list(Tq,StateCountq);
}