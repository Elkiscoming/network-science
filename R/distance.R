h = rep(0, 19)
for(i in 1:length(metaboliteIDs)){
  p = bfs(g1, i, neimode = c("out"), dist=TRUE)[['dist']]
  p = p[p != 0]
  h2 = hist(p,breaks=1:20)[['counts']]
  h = h + h2
}