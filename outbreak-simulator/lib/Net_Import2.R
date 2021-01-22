Net_Import2<-function(File,edgelist=TRUE,adjacencymatrix=FALSE){
 
  
  if(edgelist==TRUE){
   L=scan(File);
  lL=length(L);
  i=seq(3,lL,3)
  L1=L[i-2];
  L2=L[i-1];
  L3=L[i];
  N=max(c(max(L1),max(L2)));
     }
  
 
  
  
   if(adjacencymatrix==TRUE)
   {
        admat=as.matrix(read.table(File, header = FALSE)); 
        N=dim(admat)[1];
        dum=N*N;
        L1=vector("integer",dum);
        L2=vector("integer",dum); 
        L3=vector("numeric",dum);
        avi=0;
        for (i in 1:N){
      
            for(j in 1:N){
        
                 if (admat[i,j]>0){
                   avi=avi+1;
                   L1[avi]=i;
                   L2[avi]=j;
                   L3[avi]=admat[i,j];
                             }
              }
      }
    
        L1=L1[1:avi];
        L2=L2[1:avi];
        L3=L3[1:avi];
        }
  
  
  ft=NeighborhoodDataWD(N,L1,L2,L3);
  I1=matrix(ft[[2]],1,N);
  I2=matrix(ft[[3]],1,N);
 list(list(ft[1],I1,I2),N);
 
  
  
   }

