library(jsonlite)
library(igraph)
setwd("/home/erfan/Desktop/University/95-summer/network-science/e.coli/datas")

df <- readLines("iECW_1372.json")
json <- fromJSON(paste(df, collapse = ""))
print('json built')
reactions <- json['reactions'][[1]]
metabolites <- json['metabolites'][[1]]
metaboliteIDs <- list()
for (i in 1:nrow(metabolites)){
  metaboliteIDs[[ i ]] <- metabolites[i,][['id']]
}
print('metabolites created')
g1 <- graph(edges=c(), n=length(metaboliteIDs))
for (i in 1:nrow(reactions)){
  if(i %% 100 == 0){
    print(i)
  }
  reaction <- reactions[i,]
  reactionMetabolities <- names(reaction[['metabolites']])[!is.na(reaction[['metabolites']])]
  reactionMetabolitiesC <- reaction[['metabolites']][!is.na(reaction[['metabolites']])]
  
  products <- list()
  for(j in 1:length(reactionMetabolities)){
    if(reactionMetabolitiesC[j] > 0){
      id <- which(metaboliteIDs %in% c(reactionMetabolities[j]))
      products <- c(products, id)
    }
  }
  for(j in 1:length(reactionMetabolities)){
    if(reactionMetabolitiesC[j] < 0)
      for(k in 1:length(products)){
        id <- which(metaboliteIDs %in% c(reactionMetabolities[j]))
        if(k < length(products)){
          g1 <- add_edges(g1, edges=c(id, products[[k]]))
        }
      }
  }
}
dd <- degree_distribution(g1)
plot(dd)