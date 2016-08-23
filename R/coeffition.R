neighbours <- ego(g1, 1, mode=c("out"))
ccs <- rep(0, length(metaboliteIDs))
nns <- rep(0, length(metaboliteIDs))
for(i in 1:length(metaboliteIDs)){
  if(i %% 100 == 0){
    print(i)
  }
  nn <- length(neighbours[[i]])
  cc <- 0
  for(j in 1:nn){
    for(k in (j+1):nn){
      if(k > nn)
        break
      ts <- neighbours[[ neighbours[[i]][j] ]]
      ts <- ts[ ts == neighbours[[i]][k] ]
      if(length(ts[ts == neighbours[[i]][k]]) > 0)
        cc <- cc + 1
      ts <- neighbours[[ neighbours[[i]][k] ]]
      if(length(ts[ts == neighbours[[i]][j]]) > 0)
        cc <- cc + 1
    }
  }
  ccs[i] <- (2 * cc) / (nn * (nn - 1))
  nns[i] <- nn
}