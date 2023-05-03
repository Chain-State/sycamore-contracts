# #!/bin/bash

# arg1=$1;shift
# array=( "$@" )
# last_idx=$(( ${#array[@]} - 1))
# arg2=${array[$last_idx]}
# unset array[$last_idx]

# echo "arg1=$arg1"
# echo "arg2=$arg2"
# echo "array contains:"
# printf "%s\n" "${array[@]}"

# function foo {
# 	local -n data_ref=$1
# 	echo ${data_ref[a]} ${data_ref[b]}
# }

# declare -A data
# data[a]="test1"
# data[b]="test2"
# foo data


#!/bin/bash

# Define a space separated string
string="item1 item2 item3"

# Convert the string to an array
read -a array <<< $1
# 
# Loop through the array and print each item
for item in "${array[@]}"
do
  echo "$item"
  done

