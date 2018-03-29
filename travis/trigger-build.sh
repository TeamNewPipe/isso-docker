#! /bin/bash

log() { echo $(tput setaf 2)$(tput bold)"$*"$(tput sgr0) ; }

branch="${BRANCH:=master}"
commit="${COMMIT:=$(curl -s https://api.github.com/repos/TeamNewPipe/isso/commits/$branch | jq -r '.sha')}"
echo "$commit"

log "Trigger build for branch $branch, commit $commit"
echo

read -r -d '' body <<EOF
{
  "request": {
    "message": "Build branch $branch, commit $commit",
    "branch":"master",
    "config": {
      "env": {
        "BRANCH": "$branch",
        "COMMIT": "$commit"
      }
    }
  }
}
EOF

token=$(travis token --org)

curl -s -X POST \
   -H "Content-Type: application/json" \
   -H "Accept: application/json" \
   -H "Travis-API-Version: 3" \
   -H "Authorization: token $token" \
   -d "$body" \
   https://api.travis-ci.org/repo/TeamNewPipe%2Fisso-docker/requests
