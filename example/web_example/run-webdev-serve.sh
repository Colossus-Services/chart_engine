#!/bin/bash

export PATH="$PATH":"$HOME/.pub-cache/bin"

argRelease=""

if [[ $1 == 'r' ]]; then
  argRelease="--release"
fi


pub global activate webdev

webdev serve --hostname 0.0.0.0 $argRelease

