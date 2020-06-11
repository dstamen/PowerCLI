#!/bin/sh
echo "Updating Master branch"
git add --all && git commit -m "$(curl -s whatthecommit.com/index.txt)" && git push