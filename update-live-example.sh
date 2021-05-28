#!/bin/bash

git fetch
git checkout gh-pages
git pull

git merge master -m "Merge master into gh-pages"

rm -rf .dart_tool
rm -rf example/www

dart pub get
dart pub global run webdev build -o example:example/www -r

git add example/www/*

git commit -m "Update live web example"
git push

rm -rf .dart_tool
rm -rf example/www
rm -rf doc

git checkout master

dart pub get
