# to prune old in/out links from database

prune_links = function(file_id, location, custom_in = NULL, custom_out = NULL){

  # connect to metacomb db
  .comb_db = metacomb::comb_connect()

  # disconnect on exit
  on.exit(DBI::dbClearResult(.comb_db))
  on.exit(DBI::dbDisconnect(.comb_db))

  # get all in/out in script
  script_in = metacomb::comb_links(location = location, direction = "in", custom_in = custom_in, custom_out = custom_out)
  script_out = metacomb::comb_links(location = location, direction = "out", custom_in = custom_in, custom_out = custom_out)

  # get all in/out in the db
  current_links = DBI::dbGetQuery(.comb_db, paste0("
                                 SELECT * FROM file_flow
                                 WHERE source_file_id == '", file_id, "'"))

  # make vector of archived file paths
  saved_links = unique(c(current_links$from_file_id, current_links$to_file_id))
  saved_links = saved_links[saved_links != file_id]

  # find which of these are defunct
  dead_links = saved_links[!(saved_links %in% c(script_in, script_out))]

  # remove dead links
  sapply(dead_links, FUN = function(dead_link){

    # delete links in DB with defunct links
    DBI::dbExecute(.comb_db, paste0("
                DELETE FROM file_flow
                WHERE source_file_id == '", file_id, "'
                AND from_file_id == '", dead_link, "' OR to_file_id == '", dead_link, "';
               "))

  })
}















