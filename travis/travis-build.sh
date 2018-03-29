#! /bin/bash

set -x

# if the build does not have a BRANCH environment variable, we'll build for both
# branches
if [ "$BRANCH" != "" ]; then
    BRANCHES=( "$BRANCH" )
else
    BRANCHES=( "master" )
fi

for branch in "${BRANCHES[@]}"; do
    # to allow for checking whether the relevant commit is on the registry already
    export BRANCH="$branch"
    # set the commit
    export COMMIT=$(curl -s https://api.github.com/repos/teamnewpipe/isso/commits/"$BRANCH" | jq -r '.sha')

    # then, check whether it's a cron build
    if [ "$TRAVIS_EVENT_TYPE" == "cron" ]; then
        # it's a cron build, so make sure we don't overwrite an existing tag on the registry
        # that would be pretty annoying, as it'd modify the image hash nevertheless, causing
        # unnecessary updates for users who update regularly
        if curl --silent https://quay.io/v1/repositories/teamnewpipe/isso/tags | grep -q "$COMMIT"; then
            echo "Image for commit $COMMIT exists on registry -- skipping build"
            continue
        fi
    fi

    # either it's not a cron build or the tag is missing on the registry
    # thus, we can build and push the image
    # if the build is triggered externally, the override is probably intentional, e.g. when
    # this repository has been updated, and an older tag needs to be updated asap
    exec bash -x build.sh --push
done
