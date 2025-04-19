#!/bin/zsh

function timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 100); do time $shell -i -c exit; done
}

