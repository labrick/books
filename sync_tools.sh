#!/bin/bash

cd `dirname $0`

git pull --prune

git add *
git add .marks
git commit -m "auto sync at `date`"
git push -u origin master
