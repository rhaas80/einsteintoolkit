#!/bin/bash

git submodule update --init --recursive --depth 1

awk -vFS='[][ \t"=]+' '/path/{sm=$3} /branch/{b=$3} /upstreamtype/{print sm,b}' .gitmodules | while read m b ; do
  cd $m
  pwd
  git fetch
  git checkout origin/$b
  cd - >/dev/null
  git add $m
done

msg="updated submodules

$(git diff --submodule=log --cached)
"
if git commit -m "$msg" ; then
  git push origin HEAD:master
fi