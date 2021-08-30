# to detect all input/output files in a script and return them if they are valid WITHIN THIS PROJECT

comb_links = function(location, direction, custom_in = NULL, custom_out = NULL){

  # set if looking for in or out functions
  if(direction == "in"){inout_functions = c(

    "read.csv", "readRDS", "read_csv","readLines", custom_in

    )} else
  if(direction == "out"){inout_functions = c(

    "write.csv", "saveRDS", "tmap_save", "write_csv",
    "pdf", "svg", "cairo_pdf", "cairo_ps", "bmp", "jpeg", "png", "tiff",
    custom_out

    )} else
  {stop("Invalid direction, pleae use 'in' or 'out'.")}

  # load in script
  script = readLines(location)

  # clean script
  script = clean_script(script)

  # find path varaibles
  vari_paths = script[grepl("^.+?\\s?=\\s?[\"\'\`].+?[\"\'\`]$|^.+?\\s?<-\\s?[\"\'\`].+?[\"\'\`]$", script)]
  vari_paths = unlist(stringr::str_extract_all(vari_paths, "\".*?\"|\'.*?\'"))
  vari_paths = unname(sapply(vari_paths, gsub, pattern = '\"', replacement = ''))

  if(length(vari_paths) != 0){

    vari_paths = vari_paths[sapply(vari_paths, FUN = function(item){file.exists(item) | dir.exists(item)})]

    # get the variables containing these paths
    replaced_inout = sapply(vari_paths, FUN = function(vari_path){

      # find the line in script with this assignment
      assigned_vari = script[grepl(vari_path, script)]

      # split on `=`
      assigned_vari = script[grepl(vari_path, script)]
      assigned_vari = trimws(strsplit(assigned_vari, "=|<-")[[1]][1])

      # find line varaible is used in
      used_lines = script[grepl(assigned_vari, x = script)]

      # replace those uses
      replaced_lines = gsub(assigned_vari, paste0('"', vari_path, '"'), used_lines, fixed = TRUE)

      return(replaced_lines)

    }, simplify = TRUE)

    # combine
    combined_script = c(script, unname(unlist(replaced_inout)))

  } else {combined_script = script}

  # keep only lines that have a in/out function as the vector above
  combined_script = combined_script[which(as.logical(rowSums(sapply(inout_functions, grepl, x = combined_script))))]

  # get everything in single or double quotes (possible paths)
  quotes = unlist(stringr::str_extract_all(combined_script, "\".*?\"|\'.*?\'"))

  # clean out quotes
  quotes = unname(sapply(quotes, gsub, pattern = '\"', replacement = ''))

  # stop is length 0
  if(length(quotes) == 0)(return(NA))

  # keep only valid path in this project
  paths = quotes[sapply(quotes, FUN = function(item){file.exists(item) | dir.exists(item)})]

  # return
  if(length(paths) == 0){return(NA)} else {return(paths)}

}



