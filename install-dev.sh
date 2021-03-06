#!/usr/bin/env bash

set -e -u
set -o pipefail

: '

This script allows us to install the devDependencies of a given module
after it has already been installed into `./node_modules`. The reason
this script exists is that we want to:

1) Install modules from github
2) Be able to run their tests
3) Which means we need their devDependencies
4) But the devDependencies are not installed by default

Anyone have better ideas of how to do this?

TODO: try `npm update`: https://docs.npmjs.com/cli/update

'

DEVDEPS_SCRIPT=$(pwd)/get-dev-deps.js

function build() {
    DEVDEPS=$(node ${DEVDEPS_SCRIPT})
    if [[ ! $DEVDEPS == "" ]]; then
        echo "$(pwd):"
        echo "    installing '$DEVDEPS'"
        npm install $DEVDEPS
    fi
}

for i in $(ls node_modules/); do
  (
    cd node_modules/$i
    if [[ $i == '@mapbox' ]]; then
        for j in $(ls ./); do
        (
            cd $j
            build
        )
        done
    else
        build
    fi
  )
done
