#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Needs github_scripts 1.2+
rez env github_scripts -- python $DIR/update_changelog.py -o $DIR/../src/CHANGELOG.md -i AL_USDMaya-0.23.3
