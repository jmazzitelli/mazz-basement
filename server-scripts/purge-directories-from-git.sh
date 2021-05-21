#!/bin/bash

#
# This purges all but the newest N directories from the git repo.
#

set -ue

DIR_PATTERN="molecule-tests-*"
DO_NOT_PUSH="true"
DRY_RUN="false"
GITREPO_DIRECTORY="/tmp/KIALI-GIT/kiali-molecule-test-logs"
NUM_KEEP_DIRECTORIES="10"

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -dnp|--do-not-push)           DO_NOT_PUSH="$2"           ;shift;shift;;
    -dp|--dir-pattern)            DIR_PATTERN="$2"           ;shift;shift;;
    -dr|--dry-run)                DRY_RUN="$2"               ;shift;shift;;
    -gr|--git-repo)               GITREPO_DIRECTORY="$2"     ;shift;shift;;
    -nkd|--num-keep-directories)  NUM_KEEP_DIRECTORIES="$2"  ;shift;shift;;
    -h|--help)
      cat <<HELPMSG

Valid command line arguments:
  -dnp|--do-not-push <true|false>: If "true" do not push the results to the remote repo. This is a safety measure allowing you to double check before pushing manually.
  -dp|--dir-pattern <glob pattern>: When searching for directories in the git repo, this is the glob pattern used.
  -dr|--dry-run <true|false>: If "true" do not purge anything; otherwise purge as usual.
  -nkd|--num-keep-directories <N>: The number of newest directories to keep.
  -gr|--git-repo <dir>: Directory where the local git repo is.

HELPMSG
      exit 1
      ;;
    *)
      echo "Unknown argument [$key]. Aborting."
      exit 1
      ;;
  esac
done

# Validate config

[ ! -d "${GITREPO_DIRECTORY}/.git" ] && echo "ERROR: --git-repo does not appear to have git content: ${GITREPO_DIRECTORY}" && exit 1
! [[ ${NUM_KEEP_DIRECTORIES} =~ ^[0-9]+$ ]] && echo "ERROR: --num-keep-directories must be an integer: ${NUM_KEEP_DIRECTORIES}" && exit 1
[ "${DRY_RUN}" != "true" -a "${DRY_RUN}" != "false" ] && echo "ERROR: --dry-run must be 'true' or 'false'." && exit 1
[ "${DO_NOT_PUSH}" != "true" -a "${DO_NOT_PUSH}" != "false" ] && echo "ERROR: --do-not-push must be 'true' or 'false'." && exit 1

if [ "${DRY_RUN}" == "true" -a "${DO_NOT_PUSH}" == "false" ]; then
  echo "Dry run is enabled - setting '--do-not-push' to 'true'"
  DO_NOT_PUSH="true"
fi

echo
echo "===== SETTINGS ====="
echo DIR_PATTERN=$DIR_PATTERN
echo DO_NOT_PUSH=$DO_NOT_PUSH
echo DRY_RUN=$DRY_RUN
echo GITREPO_DIRECTORY=$GITREPO_DIRECTORY
echo NUM_KEEP_DIRECTORIES=$NUM_KEEP_DIRECTORIES
echo "===== SETTINGS ====="
echo

# Start purging

cd ${GITREPO_DIRECTORY}

if [ "${DRY_RUN}" == "true" ]; then
  echo "DRY RUN: git fetch --all"
  echo "DRY RUN: git checkout master"
  echo "DRY RUN: git checkout --orphan latest_master"
else
  git fetch --all
  git checkout master
  git checkout --orphan latest_master
fi

ALL_DIRECTORIES=($(ls -1dt ${GITREPO_DIRECTORY}/${DIR_PATTERN}))
for dir in ${ALL_DIRECTORIES[@]:0:${NUM_KEEP_DIRECTORIES}};
do
  echo "Keeping directory: $dir"
done

for dir in ${ALL_DIRECTORIES[@]:${NUM_KEEP_DIRECTORIES}};
do
  echo "PURGING DIRECTORY: $dir"
  if [ "${DRY_RUN}" == "true" ]; then
    echo "DRY RUN: git rm -rf \"$dir\""
  else
    git rm -rf "$dir"
  fi
done

if [ "${DRY_RUN}" == "true" ]; then
  echo "DRY RUN: git commit -m 'the current files'"
  echo "DRY RUN: git branch -D master"
  echo "DRY RUN: git branch -m master"
else
  git commit -m 'the current files'
  git branch -D master
  git branch -m master
fi

if [ "${DO_NOT_PUSH}" == "true" ]; then
  echo "The results will NOT be pushed to the remote repo."
  echo "At this point you should do the following:"
  echo "  cd ${GITREPO_DIRECTORY}"
  echo "  git push -f origin master"
  echo "  git branch --set-upstream-to=origin/master master"
  echo "  git gc"
else
  git push -f origin master
  git branch --set-upstream-to=origin/master master
  git gc
fi
