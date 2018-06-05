#!/usr/bin/env bash

RELEASES_PATH=./releases
NUM_KEPT_RELEASES=5

init() {
  mkdir $RELEASES_PATH
}

list_releases() {
  ls -1r $RELEASES_PATH
}

current_release() {
  local current=`readlink current`
  echo "${current##*/}"
}

last_release() {
  echo `ls -1r $RELEASES_PATH | head -n 1`
}

previous_to_last_release() {
  echo `ls -1r $RELEASES_PATH | head -n 2 | tail -n 1`
}

deploy() {
  release=$(last_release)
  ln -sfn $RELEASES_PATH/$release current
}

rollback() {
  release=$(previous_to_last_release)
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
  local currdate=`date '+%Y%m%d%H%M%S'`
  mkdir $RELEASES_PATH/$currdate
  cp $1 $RELEASES_PATH/$currdate
  cd $RELEASES_PATH/$currdate
  unzip $1
  rm $1
}

run() {
  cd $RELEASES_PATH/$(last_release)
  $@
}

while test $# -ne 0; do
  arg=$1; shift
  case $arg in
    init) init; exit ;;
    list) list_releases; exit ;;
    last) last_release; exit ;;
    prev|previous) previous_to_last_release; exit ;;
    curr|current) current_release; exit ;;
    dep|deploy) deploy; exit ;;
    rollback) rollback; exit ;;
    clean) clean_old_releases; exit ;;
    rel|release) new_release $1; exit ;;
    run) run $@; exit ;;
    *)
  esac
done
