# Metacomb: Untangle your Project

## Install

Install metacmob using:
```
devtools::install_github("epsian/metacomb")
```

## Usage

### Setup

To use metacomb, first open your RStudio project. In the console enter:

```
metacomb::comb_create_cache()
```

This will create a `./metacomb/` directory in your working directory, inside of which will be a SQLite database for metacomb. For now it is expected all paths are relative to this location. If you run this command again with the `wipe = TRUE` argument, it will empty the database.

### In Scripts

For any script you want to register with metacomb, run:

```
metacomb::metacomb("UNIQUE_NAME")
```

Run this from within the script editor inside the file you want to register. The `UNIQUE_NAME` can be anything, but it should be something that you can recognize as this file. If your script has unique in/out function, you can specify them with the `custom_in` and `custom_out` arguments. There will be some console output when you run these you can ignore if not errors.

### Graph

Once you have entered all the scripts you want to include, you can run:

```
metacomb::comb_network()
```

This will visualize your project data flow!
