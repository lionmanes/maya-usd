#!/bin/bash

################################################################################
#
# This script will compare the internal develop branch and the opensource one.
# If the internal branch has new commits since the last push AND the external
# has not been updated since (by merging new pull requests), it will
#   - push the new commits to the develop branch of the opensource repository
#   - update the internal develop branch.
#
# Parsing/filtering relies on the git subtree connection between the internal
# and open source repositories.
#
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

die () {
    echo "$@" 1>&2
    exit 1
}

find_latest_squash () {
# Get the latest commit pulled from opensource we're currently based on.
# Also get the commit holding the squashed opensource pull.
#
# TODO: Make sure that earlier in the chain we always subtree-pull using
#       squash.
#
# (Code copied from git subtree.)
    dir=$1

    git log --grep="^git-subtree-dir: $dir/*\$" \
            --pretty=format:'START %H%n%s%n%n%b%nEND%n' HEAD |
    while read a b junk
    do
        case "$a" in
        START)
            sq="$b"
            ;;
        git-subtree-mainline:)
            main="$b"
            ;;
        git-subtree-split:)
            sub="$(git rev-parse "$b^0")" ||
            die "could not rev-parse split hash $b from commit $sq"
            ;;
        END)
            if test -n "$sub"
            then
                if test -n "$main"
                then
                    # a rejoin commit?
                    # Pretend its sub was a squash.
                    sq="$sub"
                fi
                echo "$sq" "$sub"
                break
            fi
            sq=
            main=
            sub=
            ;;
        esac
    done
}

prefix=src
oss_url=https://github.al.com.au/fabricem/AL_USDMayaNewSyncTest_ext.git

# This script is supposed to be run on Jenkins, during a push event, only for
# the develop branch. A filter is therefore going to present in the Jenkinsfile,
# just double check here as we don't want to push feature branches stuff!!!
# (Jenkins checkouts are in detached mode, compare SHAs)
current_sha=$(git rev-parse HEAD)
develop_sha=$(git rev-parse origin/develop)
if test "$current_sha" != "$develop_sha"
then
    die "Only allowed to work with develop branch"
fi

# This will give us FETCH HEAD and is also needed by git subtree to work
# properly.
git fetch --quiet $oss_url develop

# This is the external opensource develop HEAD commit.
oss_fetched_commit=$(git rev-parse --revs-only FETCH_HEAD) || exit $?

# Each `git subtree pull --squash` will have created a squash commit
# wich will be merged in the main branch.
# We want to know all the commit which have been made in 'src'
# (the subtree folder) since this merge.

last_squash="$(find_latest_squash $prefix)"
if test -z "$last_squash"
then
    die "Can't find last opensource merge pull"
fi
set $last_squash

# This is the opensource parent commit from the last subtree pull.
int_squash_commit=$1

# Get its child commit.
int_squash_merge_commit=$(git rev-list HEAD ^$int_squash_commit --merges -1 \
                                                                -- $dir)

# This is the opensource commit we're currently based on.
oss_pulled_commit=$2

# Now we can look for new commits in the subtree folder if any.
commits="$(git rev-list HEAD ^$int_squash_merge_commit -- $prefix)"

if test -z "$commits"
then
    echo "Nothing to push to opensource."
    exit 0
else
    # New commits to pushed to opensource.
    if test "$oss_pulled_commit" = "$oss_fetched_commit"
    then
        # Nothing to pull from opensource, we're ok to push.
        git subtree push -q -P src $oss_url develop || exit $?

        # Update develop.
        git subtree pull -m "Merge from $oss_url" -q -P src $oss_url develop \
                         --squash || exit $?
        git push --quiet origin HEAD:develop || exit $?

        echo -e "${GREEN}The opensource repository has been updated.${NC}"
    else
        echo -e "${RED}Some commits have to be pushed to the opensource repo,"
        echo -e "but the internal repo has to be updated first${NC}"
        exit 1
    fi
fi
