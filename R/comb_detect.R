# to detect all input/output files in a script and return them if they are valid WITHIN THIS PROJECT

comb_detect = function(location, direction, custom_functions = NULL){

  # set if looking for in or out functions
  if(direction == "in"){inout_functions = c("read.csv", "readRDS", custom_functions)} else
  if(direction == "out"){inout_functions = c("write.csv", "saveRDS", "tmap_save", custom_functions)} else
  {stop("Invalid direction, pleae use 'in' or 'out'.")}

  # load in script
  script = readLines(location)

  # remove all comments
  script = gsub("#.+$", "", script)

  # remove empties
  script = script[script != ""]

  # combine lines with pipe-likes
  # start with the last line and work up
  for(i in length(script):2){

    # combine lines if line ends with +, %>%, or |>

    # does this like end with a trailing pipe-like?
    if(grepl("(?:%>%)\\s*$|(?:\\+)\\s*$|(?:\\|>)\\s*$", script[i-1])){

      # then combine with next line
      script[i-1] = paste0(script[i-1], script[i], collapse = " ")

      # NA out current line
      script[i] = NA

    }

    # does this like end with a starting pipe-like?
    if(grepl("^\\s*(?:%>%)|^\\s*(?:\\+)|^\\s*(?:\\|>)", script[i])){

      # then combine with next line
      script[i-1] = paste0(script[i-1], script[i], collapse = " ")

      # NA out current line
      script[i] = NA

    }

  }

  # remove new NAs
  script = script[!is.na(script)]

  # keep only lines that have a in/out function as the vector above
  script = script[which(as.logical(rowSums(sapply(inout_functions, grepl, x = script))))]

  # get everything in single or double quotes (possible paths)
  quotes = unlist(stringr::str_extract_all(script, "\".*?\"|\'.*?\'"))

  # clean out quotes
  quotes = unname(sapply(quotes, gsub, pattern = '\"', replacement = ''))

  # keep only valid path in this project
  paths = quotes[sapply(quotes, FUN = function(item){file.exists(item) | dir.exists(item)})]

  # return
  if(length(paths) == 0){return(NA)} else {return(paths)}

}



