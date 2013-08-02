#!/bin/sh

#set -x

ECHO_PREFIX='***'

DEPLOY_AUTO=$(git config hooks.deployAuto)
DEPLOY_TYPE=$(git config hooks.deployType)

REF=$1
BRANCH_NAME=$(echo ${REF} | awk -F/ '{print $NF}')

if [ "${DEPLOY_AUTO}" = 'true' ]; then
  DEPLOY_BRANCH=$(git config "hooks.deployBranch${BRANCH_NAME}")
  if [ "${DEPLOY_BRANCH}" = 'true' ]; then
    echo "${ECHO_PREFIX} Automatic deployment configured for this repository on branch ${BRANCH_NAME}"
    SCRIPT_DIR="$($(which dirname) "$0")/.."
    case ${DEPLOY_TYPE} in
      drupal)
        DEPLOY_NAME=$(git config "hooks.deployB${BRANCH_NAME}Name")
        #WHO=$(who am i| awk '{print $1}')
        : ${GL_USER:="bash"}
        sudo ${SCRIPT_DIR}/sudo/autodeploy-drupal.sh ${DEPLOY_NAME} ${BRANCH_NAME} ${GL_USER}
        ;;
      drupal_profile)
        DEPLOY_NAME=$(git config "hooks.deployB${BRANCH_NAME}Name")
        MAKEFILE_NAME=$(git config "hooks.deployMakeFile")
        : ${GL_USER:="bash"}
        sudo ${SCRIPT_DIR}/sudo/autodeploy-drupal_profile.sh ${DEPLOY_NAME} ${BRANCH_NAME} ${GL_USER} ${MAKEFILE_NAME}
        ;;
      moodle)
        DEPLOY_NAME=$(git config "hooks.deployB${BRANCH_NAME}Name")
        : ${GL_USER:="bash"}
        sudo ${SCRIPT_DIR}/sudo/autodeploy-moodle.sh ${DEPLOY_NAME} ${BRANCH_NAME} ${GL_USER}
      *)
        echo "!!! ERROR: unsupported deployType '${DEPLOY_TYPE}'"
        ;;
    esac
  fi
fi

exit 0
