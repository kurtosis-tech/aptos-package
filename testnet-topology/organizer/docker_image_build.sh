#!/usr/bin/env bash
# 2021-07-08 WATERMARK, DO NOT REMOVE - This script was generated from the Kurtosis Bash script template

set -euo pipefail   # Bash "strict mode"
script_dirpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "$script_dirpath"

# ==================================================================================================
#                                             Constants
# ==================================================================================================
IMAGE="kurtosistech/aptos-package-organizer"

# ==================================================================================================
#                                             Main Logic
# ==================================================================================================

# The below is adopted from: https://github.com/kurtosis-tech/kurtosis/blob/2c1ca7a1ad90668108ccf3dfd3aa71708164163e/scripts/docker-image-builder.sh#L60
buildx_platform_arg="linux/arm64,linux/amd64"
#buildx_platform_arg="linux/amd64"
kurtosis_docker_builder="kurtosis-docker-builder"
docker_buildx_context='kurtosis-docker-builder-context'
dockerfile_filepath="${script_dirpath}/Dockerfile"
dockerfile_dirpath="."

version_tag="$(bash get-docker-tag.sh)"
image_tags_concatenated="-t $IMAGE:$version_tag -t $IMAGE:latest"

echo "Building image: $IMAGE:$version_tag and $IMAGE:latest"

if docker buildx inspect "${kurtosis_docker_builder}" &>/dev/null; then
  echo "Removing docker buildx builder ${kurtosis_docker_builder} as it seems to already exist"
  if ! docker buildx rm ${kurtosis_docker_builder} &>/dev/null; then
    echo "Failed removing docker buildx builder ${kurtosis_docker_builder}. Try removing it manually with 'docker buildx rm ${kurtosis_docker_builder}' before re-running this script"
    exit 1
  fi
fi
if docker context inspect "${docker_buildx_context}" &>/dev/null; then
  echo "Removing docker context ${docker_buildx_context} as it seems to already exist"
  if ! docker context rm ${docker_buildx_context} &>/dev/null; then
    echo "Failed removing docker context ${docker_buildx_context}. Try removing it manually with 'docker context rm ${docker_buildx_context}' before re-running this script"
    exit 1
  fi
fi

## Create Docker context and buildx builder
if ! docker context create "${docker_buildx_context}" &>/dev/null; then
  echo "Error: Docker context creation for buildx failed" >&2
  exit 1
fi
if ! docker buildx create --use --name "${kurtosis_docker_builder}" "${docker_buildx_context}" &>/dev/null; then
  echo "Error: Docker context switch for buildx failed" >&2d
  exit 1
fi

## Actually build the Docker image
#docker_buildx_cmd="docker buildx build --load --platform ${buildx_platform_arg} ${image_tags_concatenated} -f ${dockerfile_filepath} ${dockerfile_dirpath}"
docker_buildx_cmd="docker buildx build --push --platform ${buildx_platform_arg} ${image_tags_concatenated} -f ${dockerfile_filepath} ${dockerfile_dirpath}"
echo "Running the following docker buildx command:"
echo "${docker_buildx_cmd}"
if ! eval "${docker_buildx_cmd}"; then
  echo "Error: Docker build failed" >&2
  exit 1
fi
