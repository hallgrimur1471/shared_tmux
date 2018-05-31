#!/usr/bin/env bash

# cd to the directory of this script
tests_dir=$(dirname "$0")
tests_dir=$(readlink -f $project_root) # make sure . gets expanded
cd $tests_dir

while [ true ]; do
  n=$(( $n + 1 ))
  echo $n
  wait
done

#./signal_slave.sh &
#slave_pid=$!
#
#echo "slave running at $pid"
#echo "ready, set ..."
#sleep 2
#echo "go!"
#kill -SIGCONT $pid
