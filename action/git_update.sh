#!/bin/bash

VERSION=""

# Get parameters

while getops v: flag
do
	case "${flag}" in
	v) VERSION=${OPTARG};;
	esac
done

# Get the lates git tag, if unavailable use 0.1.0
git fetch --prune --unshallow 2>/dev/null
CURRENT_VERSION=`git describe --abrev=0 --tags 2>/dev/null`

if [[ $CURRENT_VERSION == '' ]]
then 
	CURRENT_VERSION='0.1.0'
fi
echo "Current Version: $CURRENT_VERSION"

# Replace . with space for easier splitting
CURRENT_VERSION_PARTS=(${CURRENT_VERSION//./ })

# Get number parts
VNUM1=${CURRENT_VERSION_PARTS[0]}
VNUM2=${CURRENT_VERSION_PARTS[1]}
VNUM3=${CURRENT_VERSION_PARTS[2]}

if [[ $VERSION == 'major' ]]
then
	VNUM1=v$((VNUM1+1))
elif [[ $VERSION == 'minor' ]]
then
	VNUM2=$((VNUM2+1))
elif [[ $VERSION == 'patch' ]]
then
	VNUM3=$((VNUM3+1))
else
	echo "No Version type (semver.org) or incorrect type specified, try: [major, minor , patch]"
	exit 1
fi

NEW_TAG="$VNUM1.$VNUM2.$VNUM3"
echo "($VERSION) updating $CURRENT_VERSION to $NEW_TAG"

# Check if the current one has a tag
GIT_COMMIT=`git rev-parse HEAD`
NEEDS_TAG=`git descibe --contains $GIT_COMMIT 2>/dev/null`

if [ -z "$NEEDS_TAG" ]; then
	echo "Tagged with $NEW_TAG"
	git tag $NEW_TAG
	git push --tags
	git push
else
	echo "Tag already available"
fi

echo ::set-output name=new-version::$NEW_TAG

exit 0