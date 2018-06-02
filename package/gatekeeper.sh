#!/usr/bin/env bash

# cd to the directory of this script
project_root=$(dirname "$0")
project_root=$(readlink -f $project_root) # make sure . gets expanded
cd $project_root

host_size_file="./host_size.conf"

while [ true ]; do
  user_lines="`tput lines`"
  user_columns="`tput cols`"
  host_lines="`cat $host_size_file | head -2 | tail -1 | awk '{print $2}'`"
  host_columns="`cat $host_size_file | head -3 | tail -1 | awk '{print $2}'`"

  cat $host_size_file
  echo "`readlink -f .`"
  echo "$user_lines, $host_lines, $user_columns, $host_columns"
  if [[ (( $user_lines < $host_lines )) || \
     (( $user_columns < $host_columns )) ]]; then
    diff_lines=$(($host_lines - $user_lines))
    diff_columns=$(($host_columns - $user_columns))
    if (( $diff_lines < 0 )); then
      diff_lines=0
    fi
    if (( $diff_columns < 0 )); then
      diff_columns=0
    fi
    msg="To view the shared_tmux session you must increase your terminal "
    msg+="windows size by:\n$diff_lines lines\n$diff_columns columns\n"
    msg+="(or decrease terminal font size)\n"
    printf "$msg"
  else
    tmux -S /tmp/shared_tmux attach-session -r
    exit 0
  fi
  sleep 0.1
done


