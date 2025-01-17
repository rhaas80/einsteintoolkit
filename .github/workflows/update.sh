#!/bin/bash

git submodule init
awk '/^[[]submodule "/{print "update = !git reset --quiet --mixed"} {print}' .git/config >.git/config.tmp
mv .git/config.tmp .git/config
# --init required to due Kranc containing another submodule
git submodule update --init --recursive --remote --no-fetch --depth 1 --jobs 4
git add --all

# need commits to produce list of changes
# unfortunately git fetch --shallow-exclude=refspec does not work and fails
# with an error message
for m in $(git diff --cached --name-only) ; do  (
  cd $m
  git fetch --unshallow
) done

if ! git diff --cached --exit-code --quiet ; then
  git commit -q -F - <<EOF
updated submodules

$(git diff --cached --submodule=log)
EOF
  git push
fi
