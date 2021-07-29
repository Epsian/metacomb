# To make a network dataframe for vis from database

comb_network = function(){

  # setup ####

  # connect to metacomb db
  .comb_db = metacomb::comb_connect()

  # disconnect on exit
  on.exit(DBI::dbClearResult(.comb_db))
  on.exit(DBI::dbDisconnect(.comb_db))

  # in/out ####

  # get attributes from db
  nodes = DBI::dbGetQuery(.comb_db, statement = "SELECT * FROM file_meta;")

  # get edges from db
  edges = DBI::dbGetQuery(.comb_db, statement = "SELECT * FROM file_flow;")

  # data prep ####

  ## nodes ####

  # add files in edges that are not in nodes
  edge_nodes = data.frame("file_id" = NA, "file_location" = unique(c(edges$from_file_id, edges$to_file_id)), "file_type" = "other", "last_update" = NA, "last_updater" = NA)

  # remove rows with known ids
  edge_nodes = edge_nodes[!(edge_nodes$file_location %in% nodes$file_id), ]

  # combine
  nodes = rbind(nodes, edge_nodes)

  # fill in file id if none
  nodes$file_id = ifelse(is.na(nodes$file_id), yes = nodes$file_location, no = nodes$file_id)

  # add node ids
  nodes$id_num = 1:nrow(nodes)

  # change file_id to id for plotting
  colnames(nodes)[colnames(nodes) == "file_id"] = "id"

  # add labels
  nodes$label = nodes$id

  # add hover tips
  nodes$title = paste0("<p>File ID: ", nodes$id,
                       "<br>Location: <a href='file:", normalizePath(nodes$file_location), "'>", nodes$file_location, "</a>",
                       "<br>Type: ", nodes$file_type,
                       "</p>")


  ## edges ####

  # change edge columns
  colnames(edges)[colnames(edges) == "from_file_id"] = "from"
  colnames(edges)[colnames(edges) == "to_file_id"] = "to"

  # add arrows
  edges$arrows = "to"

  ## plot ####

  # make network
  out_net = visNetwork::visOptions(visNetwork::visNetwork(nodes, edges), highlightNearest = TRUE)

  # set to fill page
  out_net$sizingPolicy$browser$fill = TRUE

  # output
  return(out_net)

}





