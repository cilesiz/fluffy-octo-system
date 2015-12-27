#!/bin/bash

echo "# fluffy-octo-system" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin git@github.com:thepericles/fluffy-octo-system.git
git push -u origin master
