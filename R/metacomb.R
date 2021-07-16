# to register the current file and all io into comb database

metacomb = function(file_id, custom_functions){

  # get current script location
  location = metacomb::current_script()

  # register current script in database
  registered = metacomb::register_file(file_id, location = location)

  # get all the ins and outs for this script
  script_in = metacomb::comb_links(location = location, direction = "in", custom_functions = custom_functions)
  script_out = metacomb::comb_links(location = location, direction = "out", custom_functions = custom_functions)

  # register those links
  sapply(script_in, FUN = function(in_file){metacomb::register_io(from = in_file, to = file_id)})
  sapply(script_out, FUN = function(out_file){metacomb::register_io(from = file_id, to = out_file)})

}
