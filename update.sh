#!/bin/bash

git submodule update --init --recursive --depth 1 --jobs 8
set -e

TOPLEVEL=$PWD
awk -vFS='[][ \t"=]+' '/path/{sm=$3} /branch/{b=$3} /upstreamtype/{print sm,b}' .gitmodules | while read m b ; do
  (
  cd $m
  git fetch
  echo git rev-parse origin/$b \>$TOPLEVEL/.git/modules/$m/HEAD
  ) &
  wait
done
wait

msg="updated submodules

$(git diff --submodule=log)
"
if git commit -a -m "$msg" ; then
  git push origin HEAD:master
fi
