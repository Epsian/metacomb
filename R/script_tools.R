# functions for dealing with scripts

# clean script

clean_script = function(script_vector){

  # remove all comments
  script = gsub("#.+$", "", script_vector)

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

  # return
  return(script)

}
