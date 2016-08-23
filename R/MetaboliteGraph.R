library(jsonlite)
library(igraph)
setwd("/home/erfan/Desktop/University/95-summer/network-science/e.coli/datas")

setOldClass("igraph")
setOldClass("proc_time")
MetaboliteGraph <- setClass(
  # Set the name for the class
  "MetaboliteGraph",
  
  # Define the slots
  slots = c(
    fileName = "character",
    reactions = "data.frame",
    metabolites = "data.frame",
    metaboliteIDs = "list",
    pre = 'proc_time',
    g = "igraph"
  ),
  
  # Set the default values for the slots. (optional)
  prototype=list(
    fileName = "core.json"
  ),
  
  # Make a function that can test to see if the data is consistent.
  # This is not called if you have an initialize function defined!
  validity=function(object)
  {
    return(TRUE)
  }
)

# create a method to parse json file
setGeneric(name="parseJSON",
           def=function(theObject)
           {
             standardGeneric("parseJSON")
           }
)

setMethod(f="parseJSON",
          signature="MetaboliteGraph",
          definition=function(theObject)
          {
            df <- readLines(theObject@fileName)
            json <- fromJSON(paste(df, collapse = ""))
            print('json built')
            
            theObject@reactions <- json['reactions'][[1]]
            theObject@metabolites <- json['metabolites'][[1]]
            
            validObject(theObject)
            return(theObject)
          }
)
# create a method to extract metabolite IDs
setGeneric(name="extractMetaboliteIDs",
           def=function(theObject)
           {
             standardGeneric("extractMetaboliteIDs")
           }
)

setMethod(f="extractMetaboliteIDs",
          signature="MetaboliteGraph",
          definition=function(theObject)
          {
            theObject@metaboliteIDs <- list()
            for (i in 1:nrow(theObject@metabolites)){
              theObject@metaboliteIDs[[ theObject@metabolites[i,][['id']] ]] <- i
            }
            print('metabolites created')
            
            validObject(theObject)
            return(theObject)
          }
)

# create a method to create graph
setGeneric(name="createGraph",
           def=function(theObject)
           {
             standardGeneric("createGraph")
           }
)

setMethod(f="createGraph",
          signature="MetaboliteGraph",
          definition=function(theObject)
          {
            theObject@g <- graph(edges=c(), n=length(theObject@metaboliteIDs))
            theObject@pre <- proc.time()
            sapply(1:nrow(theObject@reactions), function(i){
              if(i %% 100 == 1){
                print(proc.time() - theObject@pre)
              }
              reaction <- theObject@reactions[i,]
              isna <- !is.na(reaction[['metabolites']])
              reactionMetabolities <- names(reaction[['metabolites']])[ isna ]
              reactionMetabolitiesC <- reaction[['metabolites']][ isna ]
              
              products <- reactionMetabolities[reactionMetabolitiesC > 0]
              reactants <- reactionMetabolities[reactionMetabolitiesC < 0]
              for(j in 1:length(reactants)){
                if(length(reactants) > 0)
                  idReactant <- theObject@metaboliteIDs[[ reactants[j] ]]
                  for(k in 1:length(products)){
                    if(length(products) > 0){
                      idProduct <- theObject@metaboliteIDs[[ products[k] ]]
                      theObject@g <- add_edges(theObject@g, edges=c(idReactant, idProduct))
                    }
                  }
              }
            })
            validObject(theObject)
            return(theObject)
          }
)

# create a method to set json file name
setGeneric(name="setFileName",
           def=function(theObject,name)
           {
             standardGeneric("setFileName")
           }
)

setMethod(f="setFileName",
          signature="MetaboliteGraph",
          definition=function(theObject, name)
          {
            theObject@fileName <- name
            theObject@g <- graph(edges=c(), n=0)
            theObject@pre <- proc.time()
            validObject(theObject)
            return(theObject)
          }
)

# create a method to plot log log degree distribution
setGeneric(name="plotDD",
           def=function(theObject)
           {
             standardGeneric("plotDD")
           }
)

setMethod(f="plotDD",
          signature="MetaboliteGraph",
          definition=function(theObject)
          {
            dd <- degree_distribution(theObject@g)
            plot(y=log(dd), x=log(0:(length(dd)-1)))
            validObject(theObject)
            return()
          }
)

metaboliteGraph <- function(fileName){
  m <- MetaboliteGraph()
  m <- setFileName(m, fileName)
  m <- parseJSON(m)
  m <- extractMetaboliteIDs(m)
  m <- createGraph(m)
  return(m)
}