GEMF_SIM_Prob<-function(Para,Net,X0,maxNumevent,Runtime,N,numrun,timstp,comp,drawfromprobdis=FALSE,P0=NA){
  M=Para[[1]];q=Para[[2]];L=Para[[3]];A_d=Para[[4]];
  A_b=Para[[5]]; Neigh=Net[[1]];I1=Net[[2]];I2=Net[[3]];
  
  timnu<-floor(Runtime/timstp);
  Tp<-0:timnu*timstp;
  compcu<-array(as.integer(0),c(length(comp),N,timnu+1));
  ci<-vector("integer",M);  
  for(i in 1:length(comp)){ci[comp[i]]<-i};
  
  
  bil<-matrix(0,L,M);
  for(i in 1:L){bil[i,]=rowSums(A_b[,,i]);};
  
  
  bi<-list();
  temp<-matrix(0,M,L);
  for (i in 1:M){
    for(j in 1:L){ temp[,j]<-A_b[i,,j]};
    bi[[i]]<-temp;
  };
  di<-matrix(0,M,1);
  di[,1]<-rowSums(A_d)
  
  X<-vector("integer",N);
  
  Nq=matrix(0,L,N);
  
  Rn<-vector("numeric",N);
  
  
  ts<-vector("numeric",maxNumevent);
  n_index<-vector("integer",maxNumevent);
  i_index<-vector("integer",maxNumevent);
  j_index<-vector("integer",maxNumevent);
  
  pf<-vector("numeric",M);
  
  
  ######################################function f1  does the simulation
  
  f1<-function(){
   
    
   X<<-x0;
   Nq<<-Nq*0;

    for(n in 1:N){
      for(l in 1:L){
        if(I1[l,n]!=0&X[n]==q[1,l]){     
          
          for(c in I1[l,n]:I2[l,n]){ 
            m<-Neigh[[l]][1,c];
            w<-Neigh[[l]][2,c];
            Nq[l,m]<<-Nq[l,m]+w;  
          };
          
        };
      };
    };
    
   for(n in 1:N){
      Rn[n]<<-sum(bil[,X[n]]*Nq[,n])+di[X[n]];};

    R<-sum(Rn);
    

    s<-0;
    dum<-matrix(as.integer(0),L,1);
    
    Tf<<-0;
    while((s<maxNumevent)&&(R>=1e-6)&&(Tf<Runtime)){
      s<-s+1; 
      ts[s]<<--log(runif(1))/R;
     
      ns<-sample(1:N,1,prob=Rn);
      is<-X[ns];
      dum[,1]<-Nq[,ns];
      pf<<-A_d[is,]+as.vector(bi[[is]]%*%dum);
      
      js<-sample(1:M,1,prob=pf);
      
      n_index[s]<<-ns;
      j_index[s]<<-js;
      i_index[s]<<-is;
      
      X[ns]<<-js;
     
     R<-R-Rn[ns];
      Rn[ns]<<-sum(bil[,js]*Nq[,ns])+di[js];
      R<-R+Rn[ns]
      
    
      for(l in 1:L){
        
        
        if(q[1,l]==js&I1[l,ns]!=0){
          for(c in I1[l,ns]:I2[l,ns]){
            n<-Neigh[[l]][1,c];
            w<-Neigh[[l]][2,c];
            Nq[l,n]<<-Nq[l,n]+w;
            Rn[n]<<-Rn[n]+bil[l,X[n]]*w;
            R<-R+bil[l,X[n]]*w;
          }
          
        };
        
        if(q[1,l]==is&I1[l,ns]!=0){
          for(c in I1[l,ns]:I2[l,ns]){
            n<-Neigh[[l]][1,c];
            w<-Neigh[[l]][2,c];
                    
               Nq[l,n]<<-max(Nq[l,n]-w,0);
            
              Rn[n]<<-max(Rn[n]-bil[l,X[n]]*w,0);
           
              R<-R-bil[l,X[n]]*w;
                
          }
          
      
        };
        
      };
      
      Tf<<-Tf+ts[s];
    };
    lasteventnumber<<-s;
    if((Tf<Runtime)&& (s==maxNumevent)){print("increase maxNumevent inorder to match Runtime");};
  };
  ##########################################################################
  f2<-function(){
    T<-c(0,cumsum(ts[1:lasteventnumber]));
    dum3<-x0;
    mj=1;lif=0;
    for(i in 1:lasteventnumber){
      for(j in mj:(timnu+1)){
        if(T[i]<=Tp[j]&&Tp[j]<T[i+1]){for(n in 1:N){compcu[ci[dum3[n]],n,j]<<-compcu[ci[dum3[n]],n,j]+as.integer(1)};lif<-j;};
        if(T[i+1]<=Tp[j]){mj<-j;break;}
      }
      dum3[n_index[i]]<-j_index[i];
    };
    if(lif<(timnu+1)){for(j in (lif+1):(timnu+1)){for(n in 1:N){compcu[ci[dum3[n]],n,j]<<-compcu[ci[dum3[n]],n,j]+as.integer(1)}}};
  };
  
  
  #######running the simulation
  
  if(drawfromprobdis==FALSE){x0<-X0;
  for(i in 1:(numrun)){
    lasteventnumber<-0;
    Tf<-0; 
    f1();
    if(lasteventnumber>0){f2();};
    print(i);};
  };
  
  
  
  if(drawfromprobdis==TRUE){
    x0<-vector("integer",N);
    for(i in 1:(numrun)){
      for(n in 1:N){x0[n]<-sample(1:M,1,prob=P0[,n]);}
      lasteventnumber<-0;
      Tf<-0;
      f1();
      if(lasteventnumber>0){f2();}
      print(i);};
  };
  
  
  list(Tp,compcu);}