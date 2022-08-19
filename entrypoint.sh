#!/usr/bin/env bash
set -x

pushd "${GITHUB_WORKSPACE}" || ( echo "Error accessing ${GITHUB_WORKSPACE}" && exit 1 )

if [ -z "${INPUT_TOKEN}" ]; then
  echo "Balena API token is required" && exit 1
fi

INPUT_ENVIRONMENT=${INPUT_ENVIRONMENT:-balena-cloud.com}
if [ -n "${INPUT_DRAFT}" ] && [ "${INPUT_DRAFT}" == "yes" ]; then
  STATUS="--draft"
fi

balena=$(command -v balena)
export BALENARC_BALENA_URL="${INPUT_ENVIRONMENT}"
"${balena}" login --token "${INPUT_TOKEN}"

if ! "${balena}" fleet "${INPUT_FLEET}" > /dev/null 2>&1 ; then
  "${balena}" fleet create "${INPUT_FLEET}" --type "${INPUT_TYPE}" --organization "${INPUT_ORGANIZATION}"
fi

if result=$("${balena}" push -d "${INPUT_FLEET}" --source "${INPUT_CONTENTS:-$(pwd)}" ${STATUS}); then
  if [ -n "${result}" ]; then
    releaseID=$(echo "${result}" | jq -r '.releaseId')
    echo "Deployed to  ${INPUT_ENVIRONMENT}:${INPUT_ORGANIZATION}/${INPUT_FLEET} as ${STATUS##--} at ${releaseID}"
    echo "::set-output name=release-id::$releaseID"
    exit 0
  fi
fi
exit  1
