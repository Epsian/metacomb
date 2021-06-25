# function to register the current file into the metacomb database

comb_register = function(file_id, type = "script"){

  # connect to metacomb db
  .comb_db = metacomb::comb_connect()

  # disconnect on exit
  on.exit(DBI::dbClearResult(.comb_db))
  on.exit(DBI::dbDisconnect(.comb_db))

  # find file location
  location = ifelse(type == "script", metacomb::comb_script(), NA)

  # make info to input
  file_meta = paste("file_id" = paste0("'", file_id, "'"),
                    "file_location" = location,
                    "file_type" = paste0("'", type, "'"),
                    "last_updater" = paste0("'", Sys.info()["user"], "'"), sep = ", ")

  # now try to enter the info
  out = DBI::dbExecute(.comb_db, paste0("
                       INSERT OR REPLACE INTO file_meta (file_id, file_location, last_updater)
                       VALUES (", file_meta,")
                       "))

}
