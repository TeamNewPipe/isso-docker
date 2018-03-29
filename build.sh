#! /bin/bash

# export BRANCH and/or COMMIT to modify the build process

log() { echo $(tput setaf 2)$(tput bold)"$*"$(tput sgr0) ; }

branch="${BRANCH:=master}"
commit="${COMMIT:=$(curl -s https://api.github.com/repos/TeamNewPipe/isso/commits/$branch | jq -r '.sha')}"

log "Building image for branch $branch, commit $commit"
echo

image_name="quay.io/teamnewpipe/isso-docker"

docker build --build-arg COMMIT="$commit" --build-arg BRANCH="$branch" -t "$image_name:$commit" -t "$image_name:$branch" .

if [ "$1" == "--push" ]; then
    log "Pushing to quay.io"
    echo

    docker push "$image_name:$commit"
    docker push "$image_name:$branch"
fi
