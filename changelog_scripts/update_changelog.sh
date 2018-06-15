#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Needs github_scripts 1.2+
rez env github_scripts-1.2.1 -- python $DIR/update_changelog.py -o $DIR/../src/CHANGELOG.md
