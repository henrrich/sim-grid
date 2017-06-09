#!/bin/sh

## ./stop_grid.sh

pid=`ps -ef | grep GridLauncher | grep -v grep | awk '{ print $2 }'`

kill -9 $pid
