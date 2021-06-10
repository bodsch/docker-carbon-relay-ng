#!/bin/bash

HADOLINT_VERSION='2.4.1'
HADOLINT_PATH='/tmp/hadolint'

if ! [[ -e "${HADOLINT_PATH}_${HADOLINT_VERSION}" ]]
then
  curl \
    --silent \
    --location \
    --output "${HADOLINT_PATH}_${HADOLINT_VERSION}" \
    "https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64"
  chmod +x "${HADOLINT_PATH}_${HADOLINT_VERSION}"
  # sudo ln -sf ${HADOLINT_PATH}_${HADOLINT_VERSION} ${HADOLINT_PATH}
fi

${HADOLINT_PATH}_${HADOLINT_VERSION} Dockerfile

shellcheck \
  --shell=bash \
  --external-sources \
  --exclude=SC1091,SC2039 \
  rootfs/init/*.sh \
