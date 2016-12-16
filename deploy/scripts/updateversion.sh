#!/usr/bin/env bash

# This script increment version number then push to github.

set -e # Exit script if any command fails.

SCRIPT_DIR=`dirname $0`

if [ "$1" = 'www' ]; then
    VERSION_FILE="$SCRIPT_DIR/../www/settings/base.py"
elif [ "$1" = 'admin' ]; then
    VERSION_FILE="$SCRIPT_DIR/../admin/settings/base.py"
else
    echo 'Usage: updateversion.sh [App Name: www|admin]'
    exit
fi

# This scripts change version number so your local branches should be up-to-date.
echo -e 'Make sure your local master/dev are up-to-date.(y/n)'
read answer
if [ "$answer" != 'y' ]; then
    echo 'Okay. Incrementing version was canceled.'
    exit
fi

# Change current branch to dev
if [ `git rev-parse --abbrev-ref HEAD` != 'dev']; then
    echo 'Change branch to dev'
    git checkout dev
fi

VERSION_TEXT=`grep 'RELEASE_NUM' $VERSION_FILE`
CURRENT_VERSION_NUMBER=${VERSION_TEXT#'RELEASE_NUM = '}
NEW_VERSION_NUMBER=`expr $CURRENT_VERSION_NUMBER + 1`

# Change version number
echo -e "\nVersion($1) will be $CURRENT_VERSION_NUMBER ===> $NEW_VERSION_NUMBER."
sed -i.bk -e "s/$CURRENT_VERSION_NUMBER/$NEW_VERSION_NUMBER/" $VERSION_FILE
# macos sed does not support -i option without prefix so we have to remove backup file after override it.
rm "$VERSION_FILE.bk"

# confirm to push this to github
git diff $VERSION_FILE
echo 'Are you sure to commit this version ? (y/n)'
read answer
if [ "$answer" != 'y' ]; then
    echo 'Okay. Commit was canceled.'
    git checkout $VERSION_FILE
    exit
fi

# push to git
git add $VERSION_FILE
git commit -m 'r++'
git push origin dev
git checkout master
git merge dev
git push origin master
