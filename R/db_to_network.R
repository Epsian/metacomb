# To make a network dataframe for vis from database

comb_network = function(hierarchical = FALSE){

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
  edge_nodes = data.frame("file_id" = NA, "file_location" = unique(c(edges$from_file_id, edges$to_file_id)), "file_type" = "other", "file_level" = NA, "last_update" = NA, "last_updater" = NA)

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

  # color nodes by type
  nodes$group = nodes$file_type

  ## edges ####

  # change edge columns
  colnames(edges)[colnames(edges) == "from_file_id"] = "from"
  colnames(edges)[colnames(edges) == "to_file_id"] = "to"

  # add arrows
  edges$arrows = "to"

  ## make network ####

  cgraph = igraph::graph_from_data_frame(edges, directed = TRUE, vertices = nodes)

  ## hierarchical plotting ####

  if(hierarchical == TRUE){

    # rename file_level for hierarchical plotting
    colnames(nodes)[colnames(nodes) == "file_level"] = "level"

    # make string NAs real NAs
    nodes$level[nodes$level == "NA"] = NA

    # get the max inward geodesic distances for each node
    cdist = igraph::distances(cgraph, mode = "in")
    cdist[is.infinite(cdist)] = NA
    nodes$in_dist = (apply(cdist, 1, max, na.rm = TRUE) + 1) # add 1 for 0s

    # put back in network
    cgraph = igraph::set_vertex_attr(cgraph, "in_dist", value = nodes$in_dist)

    # add level in is NA, keep existing (from manual assignment)
    nodes$level = ifelse(is.na(nodes$level), nodes$in_dist, nodes$level)

    # assign back to network
    cgraph = igraph::set_vertex_attr(cgraph, "level", value = nodes$level)

  }

  ## plot ####

  # take network back to visnetwork format
  plot_list = visNetwork::toVisNetworkData(cgraph)

  # make network
  out_net = visNetwork::visOptions(visNetwork::visNetwork(plot_list$nodes, plot_list$edges), highlightNearest = TRUE)

  # set to fill page
  out_net$sizingPolicy$browser$fill = TRUE

  # add legend
  out_net = visNetwork::visLegend(out_net, main = "File Type")

  # set hierarchical
  if(hierarchical == TRUE){out_net = visNetwork::visHierarchicalLayout(out_net, direction = "LR")}

  # output
  return(out_net)

}





