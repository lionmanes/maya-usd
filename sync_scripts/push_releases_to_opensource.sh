#!/bin/bash

################################################################################
#
# Scan for internal releases which have not yet been exported to the opensource
# repository.
#
################################################################################

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
		./sync_scripts/push_release.sh $tag
		res=$(( $res | $? ))
	fi
done

exit $res
