# to register the current file and all io into comb database

metacomb = function(file_id, level = NA, custom_in = NULL, custom_out = NULL){

  # get current script location
  location = metacomb::current_script()

  # register current script in database
  registered = metacomb::register_file(file_id = file_id, level = level, location = location)

  # get all the ins and outs for this script
  script_in = metacomb::comb_links(location = location, direction = "in", custom_in = custom_in, custom_out = custom_out)
  script_out = metacomb::comb_links(location = location, direction = "out", custom_in = custom_in, custom_out = custom_out)

  # register those links
  sapply(script_in, FUN = function(in_file){metacomb::register_io(from = file_id, to = in_file, source_id = file_id)})
  sapply(script_out, FUN = function(out_file){metacomb::register_io(from = out_file, to = file_id, source_id = file_id)})

  # prune dead links
  metacomb::prune_links(file_id = file_id, location = location, custom_in = custom_in, custom_out = custom_out)

}
