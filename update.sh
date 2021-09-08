#!/bin/bash

git submodule update --init --recursive --depth 1 --jobs 8

TOPLEVEL=$PWD
awk -vFS='[][ \t"=]+' '/path/{sm=$3} /branch/{b=$3} /upstreamtype/{print sm,b}' .gitmodules | while read m b ; do
  (
  cd $m
  git fetch
  git rev-parse origin/$b >$TOPLEVEL/.git/modules/$m/HEAD
  ) &
done
wait

msg="updated submodules

$(git diff --submodule=log)
"
if git commit -a -m "$msg" ; then
  git push origin HEAD:master
fi
