#!/usr/bin/env bash

RELEASES_PATH=./releases
NUM_KEPT_RELEASES=5

init() {
  mkdir -p $RELEASES_PATH
}

list_releases() {
  ls -1r $RELEASES_PATH
}

current_release() {
  local current=`readlink current`
  echo "${current##*/}"
}

latest_release() {
  echo `ls -1r $RELEASES_PATH | head -n 1`
}

previous_to_latest_release() {
  echo `ls -1r $RELEASES_PATH | head -n 2 | tail -n 1`
}

nth_last_release() {
  local nth_last_release=$1
  if [ -z "$nth_last_release" ]
  then
    nth_last_release=1
  fi
  nth_last_release=$((nth_last_release+1))
  echo `ls -1r $RELEASES_PATH | head -n $nth_last_release | tail -n 1`
}

deploy() {
  release=$(latest_release)
  ln -sfn $RELEASES_PATH/$release current
}

rollback() {
  release=$(nth_last_release $1)
  ln -sfn $RELEASES_PATH/$release current  
}

clean_old_releases() {
  releases=( $(ls -1r $RELEASES_PATH) )

  local i=0
  for release in ${releases[@]}; do
    ((i = i + 1))
    if (( $i > $NUM_KEPT_RELEASES )); then
      echo "Deleting ${RELEASES_PATH}/${release}"
      `rm -rf $RELEASES_PATH/$release`
    fi
  done
}

new_release() {
  local currdate=`date '+%Y%m%d_%H%M%S'`
  mkdir $RELEASES_PATH/$currdate
  cp $1 $RELEASES_PATH/$currdate
  cd $RELEASES_PATH/$currdate
  if [ ${1: -4} == ".zip" ]
  then
    unzip -q $1
  fi
  if [ ${1: -4} == ".bz2" ]
  then
    tar -xjf $1
  fi
  if [ ${1: -3} == ".gz" ]
  then
    tar -xzf $1
  fi
  rm $1
}

run() {
  cd $RELEASES_PATH/$(latest_release)
  $@
}

while test $# -ne 0; do
  arg=$1; shift
  case $arg in
    init) init; exit ;;
    list) list_releases; exit ;;
    last) latest_release; exit ;;
    prev|previous) previous_to_latest_release; exit ;;
    curr|current) current_release; exit ;;
    dep|deploy) deploy; exit ;;
    rollback) rollback $1; exit ;;
    clean) clean_old_releases; exit ;;
    rel|release) new_release $1; exit ;;
    run) run $@; exit ;;
    *)
  esac
done
