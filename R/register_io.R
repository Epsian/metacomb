# to create a link between two previously registered files

register_io = function(from, to, source_id){

  # connect to metacomb db
  .comb_db = metacomb::comb_connect()

  # disconnect on exit
  on.exit(DBI::dbClearResult(.comb_db))
  on.exit(DBI::dbDisconnect(.comb_db))

  # make info to input
  file_meta = paste("from_file_id" = paste0("'", from, "'"),
                    "to_file_id" = paste0("'", to, "'"),
                    "source_file_id" = paste0("'", source_id, "'"),
                    "link_key" = paste0("'", from, "_", to, "'"),
                    "last_updater" = paste0("'", Sys.info()["user"], "'"), sep = ", ")

  # now try to enter the info
  out = DBI::dbExecute(.comb_db, paste0("
                       INSERT OR REPLACE INTO file_flow (to_file_id, from_file_id, source_file_id, link_key, last_updater)
                       VALUES (", file_meta,")
                       "))

}
