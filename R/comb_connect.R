# to check if metacomb cache exists, and if so connect to it

comb_connect = function(){

  # database exists?
  if(!file.exists("./.metacomb/comb_db.sqlite")){stop("No metacomb cache exsists! Please run `metacomb_create_cache()` while the working directory is your project base.")}

  # now connect
  .comb_db = DBI::dbConnect(RSQLite::SQLite(), dbname = "./.metacomb/comb_db.sqlite")

  # return connection object
  return(.comb_db)
}
