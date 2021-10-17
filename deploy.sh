#!/bin/bash

sed -i 's/\/js/js' ./dist/index.html
sed -i 's/\/css/css' ./dist/index.html

git commit -m "deploy script fix index absolute links"

git subtree push --prefix dist origin gh-pages