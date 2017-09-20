#!/bin/bash

################################################################################
#
# This script will create a release in the opensource repository based on the
# tag given as an input argument.
#
# The input tag is in the form AL_USDMaya-X.Y.Z(.W)
#
# Context:
#
#   As the opensource and the internal repositories do not share the same SHAs
#   (git subtree rewrites the history) we cannot easily map our releases to
#   the opensource repository.
#   So this script has to find the last "extracted" (exported) commit ancestor
#   of the input tag.
#   To do so, it will extract the history preceding the input tag and do the
#   necessary checks against the opensource repository.
#
#   The opensource master branch has dedicated merge commits
#   (not part of the develop branch)
#
#    A-----B-----C-----D-----E---... (develop)
#           \     \     \
#            1-----2-----3           (master)
#
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Allows to test the script against other branches
dry_run=

USAGE="
push_release [--dry-run] version

options:
  --dry-run    do not actually merge / push
  -h           show this message
"

cleanup () {
    return
}

print_and_cleanup () {
    cleanup
    prompt=$1
    shift
    echo -e "${!prompt}$@${NC}" 1>&2
}

quit () {
    print_and_cleanup "GREEN" $@
    exit 0
}

die () {
    print_and_cleanup "RED" $@
    exit 1
}

# Test there's at least one input argument
if test "$#" -eq 0
then
    die "Please specify the internal tag which has to be exported"
fi

while test $# -gt 1
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

input_tag=$1

subtree_dir="src"
oss_url="https://github.al.com.au/rnd/AL_USDMaya_oss_ready.git"

# Test we're able to find this tag
tag_found=`git tag -l $input_tag`
if test -z "$tag_found"
then
    die "$input_tag is not a known tag"
fi

# Extract the oss version number.
# Internally (at AL) we might do a 4 digits release if it only affects
# non opensource files (e.g. package.py).
# The internal tags are in the form:
#     AL_USDMaya-X.Y.Z(.W)
# The opensource counterpart will be:
#     X.Y.Z
oss_tag=`expr "$input_tag" : \
              'AL_USDMaya-\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)'`
if test -z "$oss_tag"
then
    die "Unrecognized tag version ($input_tag), should be AL_USDMaya-X.Y.Z(.W)"
fi

# Check the status
current_status=`git status -s`
if test -n "$current_status"
then
    die "The local repository has pending commits"
fi

# Fetch the opensource history
tmp_oss_remote="_tmp_oss_remote_"
git remote add $tmp_oss_remote $oss_url || exit 1
git fetch -q $tmp_oss_remote

# Override
cleanup () {
    git remote remove $tmp_oss_remote
}

################################################################################

# Check if the previous version has been tagged

# Get the internal and oss version, sorted in lexical order
for tag in $(git tag -l --sort=v:refname);
do
    if [[ "$tag" =~ ^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* ]]; then
        oss_versions=($tag ${oss_versions[*]})
        continue
    fi
    if [[ "$tag" =~ ^AL_USDMaya-[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* ]]; then
        extract=`expr "$tag" : \
                      'AL_USDMaya-\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)'`
        # Internal versions might use 4 digits, check for duplicate.
        if [[ "$extract" != "${al_versions[0]}" ]]; then
            al_versions=($extract ${al_versions[*]})
        fi
        continue
    fi
done

# Get the index of the requested version
index=0
for version in ${al_versions[*]}
do
    if [[ "$version" = "$oss_tag" ]]
    then
        break
    else
        index=$((index+1))
    fi
done

exported=0
previous=${al_versions[$((index+1))]}
for oss in ${oss_versions[*]}
do
    if [[ "$oss" = "$previous" ]]
    then
        exported=1
    fi
done

if [[ $exported -eq 0 ]]
then
    quit "$previous needs to be exported first."
fi

################################################################################

# Get the latest subtree exported commit (before the target tag)
# To do so, extract the history in a temporary branch
tmp_branch="_tmp_subtree_split_"
git checkout -q $input_tag || exit 1
last_subtree_commit=`git subtree -q split -P $subtree_dir -b $tmp_branch`
git checkout - # Restore previous state
git branch -q -D $tmp_branch

# Look for this commit in the external repository
commit_found=`git rev-list $tmp_oss_remote/develop |\
              grep $last_subtree_commit`

if test -z "$commit_found"
then
    quit "The corresponding commits need first to be exported to " \
        $oss_url
fi

oss_master_branch=master

# Check if not already merged into opensource's master branch
commit_merged=`git rev-list $tmp_oss_remote/$oss_master_branch |\
              grep $last_subtree_commit`

if test -n "$commit_merged"
then
    quit "$last_subtree_commit is already merged in opensource master"
fi

# Override
cleanup () {
    git remote remove $tmp_oss_remote
    git checkout -
    git branch -q -D $tmp_push_branch    
}

pass_or_die() {
    if test $1 -ne 0
    then
        die $2
    fi
}

# Otherwise merge this commit into master and tag
tmp_push_branch="_tmp_oss_master_"
git checkout -q -b $tmp_push_branch $tmp_oss_remote/$oss_master_branch
git merge -q -m $oss_tag --no-ff $last_subtree_commit
pass_or_die $? "Unable to merge $last_subtree_commit"

git push $dry_run $tmp_oss_remote $tmp_push_branch:$oss_master_branch
pass_or_die $? "Unable to push opensource's master to $oss_url"

git tag $oss_tag
git push $dry_run $tmp_oss_remote $oss_tag
pass_or_die $? "Unable to push $oss_tag tag to $oss_url"

if [[ -n $dry_run ]]
then
    git tag -d $oss_tag
fi

# Clean up
cleanup
