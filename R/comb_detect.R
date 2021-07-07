# to detect all input/output files in a script

# arguments
location = "G:/Projects/work/h4ca_cartogram/src/carto.R"
inout_functions = c("read.csv", "write.csv", "readRDS", "saveRDS", "tmap_save")

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
quotes = sapply(quotes, gsub, pattern = '\"', replacement = '')

# check if valid path in this project

file = quotes[1]

if(file(file, "wb")){on.exit(close(con))} else if (inherits(file, "connection")){con <- file} else stop("bad file argument")








