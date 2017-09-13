#!/bin/bash

################################################################################
#
# Scan for internal releases which have not yet been exported to the opensource
# repository.
#
################################################################################

# Allows to test the script against other branches
dry_run=

USAGE="
push_releases_to_opensource [--dry-run]

options:
  --dry-run    do not actually merge / push
  -h           show this message
"

while test $# -gt 0
do
    opt="$1"
    shift

    case "$opt" in
    --dry-run)
        dry_run="--dry-run"
        ;;
    -h)
        echo "$USAGE"
        exit 1
        ;;
    --)
        break
        ;;
    *)
        die "Unexpected option: $opt"
        ;;
    esac
done

res=0
i=0
# Loop through tags sorted by lexical order
for tag in $(git tag -l --sort=v:refname AL_USDMaya-*)
do
	# The opensource repository has been started with AL_USDMaya-0.20.0
	# Filter previous history.
	sha=$(git rev-list -1 --after=\"2017-07-31\" $tag)
	if [[ -n "$sha" ]]
	then
		echo "Processing $tag"
		./sync_scripts/push_release.sh $dry_run $tag
		res=$(( $res | $? ))
	fi
done

exit $res
