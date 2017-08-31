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

die () {
    echo -e "${RED}$@${NC}" 1>&2
    exit 1
}

subtree_dir="src"
oss_url="https://github.al.com.au/rnd/AL_USDMaya_oss_ready.git"

# Test there's one input argument
if test "$#" -ne 1
then
    die "Please set the internal tag which has to be exported"
fi
input_tag=$1

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

# Check if not already tagged
tag_found=`git tag -l $oss_tag`
if test -n "$tag_found"
then
    git remote remove $tmp_oss_remote
    die "$oss_tag is already used"
fi

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
        al_versions=($extract ${al_versions[*]})
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
    git remote remove $tmp_oss_remote
    die "$previous needs to be exported first."
fi

################################################################################

# Get the latest subtree exported commit (before the target tag)
# To do so, extract the history in a temporary branch
current_branch=`git rev-parse --abbrev-ref HEAD`
tmp_branch="_tmp_subtree_split_"
git checkout -q $input_tag || exit 1
last_subtree_commit=`git subtree -q split -P $subtree_dir -b $tmp_branch`
git checkout -q $current_branch
git branch -q -D $tmp_branch

# Look for this commit in the external repository
commit_found=`git rev-list $tmp_oss_remote/develop |\
              grep $last_subtree_commit`

if test -z "$commit_found"
then
    git remote remove $tmp_oss_remote
    die "The corresponding commits need first to be exported to " \
        $oss_url
fi

oss_master_branch=master

# Check if not already merged into opensource's master branch
commit_merged=`git rev-list $tmp_oss_remote/$oss_master_branch |\
              grep $last_subtree_commit`

if test -n "$commit_merged"
then
    git remote remove $tmp_oss_remote
    die "$last_subtree_commit is already part of the opensource master branch"
fi

clean_git_temp () {
    git remote remove $tmp_oss_remote
    git checkout -q $current_branch
    git branch -q -D $tmp_push_branch    
}

pass_or_die() {
    if test $1 -ne 0
    then
        clean_git_temp
        die $2
    fi
}

# Otherwise merge this commit into master and tag
tmp_push_branch="_tmp_oss_mater_"
git checkout -q -b $tmp_push_branch $tmp_oss_remote/$oss_master_branch
git merge -q -m $oss_tag --no-ff $last_subtree_commit
pass_or_die $? "Unable to merge $last_subtree_commit"
 
git push $tmp_oss_remote $tmp_push_branch:$oss_master_branch
pass_or_die $? "Unable to push opensource's master to $oss_url"

git tag $oss_tag
git push $tmp_oss_remote $oss_tag
pass_or_die $? "Unable to push $oss_tag tag to $oss_url"

# Clean up
clean_git_temp
