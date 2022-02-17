#! /bin/bash

[[ -z $* ]] && echo "Changelog not specified! Aborting." && exit 1
[[ ! -f ./tardis_alpha.gma ]] && echo "File tardis_alpha.gma does not exist! Aborting." && exit 2

gmpublish update -id 2650203837 -addon tardis_alpha.gma -changes "$*"