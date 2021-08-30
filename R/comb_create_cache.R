# To create the empty directories and files for metacomb info

comb_create_cache = function(force_gen = FALSE, wipe = FALSE){

  # check required packages
  if(!any(c("RSQLite", "DBI") %in% rownames(installed.packages()))){
    install.packages(c("RSQLite", "DBI"))
  }

  # if wipe == TRUE delete all
  if(wipe){
    force_gen = TRUE
    if(file.exists("./.metacomb/comb_db.sqlite")){file.remove("./.metacomb/comb_db.sqlite")}
  }

  # test if metacombdir exists already
  if(dir.exists("./.metacomb") & force_gen == FALSE){warning("Metacomb cache already exists! To create anyway use `force_gen = TRUE`.")}
  # if not or if forced, create
  else {
    dir.create("./.metacomb", showWarnings = FALSE)
    dir.create("./.metacomb/metadata", showWarnings = FALSE)
    .comb_db = DBI::dbConnect(RSQLite::SQLite(), dbname = "./.metacomb/comb_db.sqlite")

    # set up SQLite DB tables
    ## code file meta info
    DBI::dbExecute(.comb_db, "
            CREATE TABLE IF NOT EXISTS file_meta (
            file_id TEXT PRIMARY KEY,
            file_location TEXT UNIQUE,
            file_type TEXT,
            file_level TEXT,
            last_update DATE DEFAULT (datetime('now', 'localtime')),
            last_updater TEXT
            )")

    ## file flow table
    DBI::dbExecute(.comb_db, "
            CREATE TABLE IF NOT EXISTS file_flow (
            from_file_id TEXT,
            to_file_id TEXT,
            source_file_id TEXT,
            link_key TEXT PRIMARY KEY,
            last_update DATE DEFAULT (datetime('now', 'localtime')),
            last_updater TEXT
            )")

    ## close connection
    DBI::dbDisconnect(.comb_db)
  }

}
