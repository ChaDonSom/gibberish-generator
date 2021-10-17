#!/bin/bash

sed -i 's/\/js/js/g' ./dist/index.html
sed -i 's/\/css/css/g' ./dist/index.html

git add .

git commit -m "deploy script fix index absolute links"

git subtree push --prefix dist origin gh-pages