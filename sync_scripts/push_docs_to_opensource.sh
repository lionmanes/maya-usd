#!/bin/bash

################################################################################
#
# This script will clone the internal AL_USDMaya wiki and doxygen docs repos
# in the current workspace. It will then push to their open source counterparts.
# The pull and push will use the default (and only) branches: master / gh-pages,
# respectively.
#
# Internally the doxygen docs are published to a dedicated 'documentation'
# github organisation. The open source doxygen docs is published using
# 'github pages' project basic workflow which uses a 'gh-pages' branch to
# generate the corresponding site.
#
################################################################################

### Update and push the wiki. ###
function update_and_push_wiki {
  internal_wiki_url=https://github.al.com.au/rnd/AL_USDMaya.wiki.git
  oss_wiki_url=https://github.al.com.au/fabricem/AL_USDMayaSyncTest_ext.wiki.git

  echo "Cloning iternal wiki."
  git clone -q $internal_wiki_url
  cd AL_USDMaya.wiki
  # Wiki repos have one branch by default, master. No need to checkout.
  echo "Pushing to opensource wiki."
  git push -q $oss_wiki_url master
  wiki_push_success=$?
  cd ..
  rm -rf AL_USDMaya.wiki

  if [ $wiki_push_success -ne 0 ]
  then
      exit $wiki_push_success
  fi
  echo "Wiki has been successfully updated."
}

### Update and push the doxygen documentation. ###
function update_and_push_dox {
  internal_dox_url=https://github.al.com.au/documentation/AL_USDMaya.git
  oss_gh_url=https://github.al.com.au/fabricem/AL_USDMayaSyncTest_ext.git

  echo "Cloning internal doxygen documentation."
  git clone -q $internal_dox_url || exit $?
  cd AL_USDMaya
  # Our documentation repo has only one branch, gh-pages. No need to checkout
  # the branch.
  echo "Pushing to opensource doxygen documentation."
  # Our internal process docs push process strips gh-pages history every time,
  # retaining only the two last commits, that's why push if "forced".
  git push -qf $oss_gh_url gh-pages
  dox_push_success=$?
  cd ..
  rm -rf AL_USDMaya

  if [ $dox_push_success -ne 0 ]
  then
      exit $dox_push_success
  fi
  echo "Doxygen documentation has been successfully updated."
}

update_and_push_dox
