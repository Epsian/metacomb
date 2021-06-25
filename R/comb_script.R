# to register a code file and collect it's inputs/outputs

# function to get location of current script
comb_script = function(){

  # get the path to current script
  ## test if interactive
  if(interactive()){
    # if true, use Rstudio API
    full_path = rstudioapi::getSourceEditorContext()$path
  } else {
    # otherwise treat as being sourced
    full_path = as.character(sys.call(1))[2]
  }

  # trim full path to relative
  ## how long is the path to working directory?
  full_prefix = nchar(getwd())
  ## delete that many from full path
  relative_path = paste0("'.", substr(full_path, full_prefix + 1, nchar(full_path)), "'")

  # output relative path in project
  return(relative_path)
}
