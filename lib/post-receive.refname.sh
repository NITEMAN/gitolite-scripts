#!/bin/sh

#set -x

ECHO_PREFIX='***'

DEPLOY_AUTO=$(git config hooks.deployAuto)
DEPLOY_TYPE=$(git config hooks.deployType)

REF=$1
OLD=$2
NEW=$3

BRANCH_NAME=$(echo ${REF} | awk -F/ '{print $NF}')

if [ "${DEPLOY_AUTO}" = 'true' ]; then
  DEPLOY_BRANCH=$(git config "hooks.deployBranch${BRANCH_NAME}")
  if [ "${DEPLOY_BRANCH}" = 'true' ]; then
    DEPLOY_NAME=$(git config "hooks.deployB${BRANCH_NAME}Name")
    #WHO=$(who am i| awk '{print $1}')
    : ${GL_USER:="bash"}
    #TO-DO: Ensure that $DEPLOY_NAME is not empty
    echo "${ECHO_PREFIX} Automatic deployment configured for this repository on branch ${BRANCH_NAME} to ${DEPLOY_NAME}"
    SCRIPT_DIR="$($(which dirname) "$0")/.."
    case ${DEPLOY_TYPE} in
      drupal)
        sudo ${SCRIPT_DIR}/sudo/autodeploy-drupal.sh ${DEPLOY_NAME} ${BRANCH_NAME} ${GL_USER}
        ;;
      drupal-make)
        MAKEFILE_NAME=$(git config "hooks.deployB${BRANCH_NAME}MakeFile")
        MAKEFILE_NAME=${MAKEFILE_NAME:-"$(git config 'hooks.deployMakeFile')"};
        sudo ${SCRIPT_DIR}/sudo/autodeploy-drupal-make.sh ${DEPLOY_NAME} ${BRANCH_NAME} ${GL_USER} ${MAKEFILE_NAME}
        ;;
      moodle)
        sudo ${SCRIPT_DIR}/sudo/autodeploy-moodle.sh ${DEPLOY_NAME} ${BRANCH_NAME} ${GL_USER}
        ;;
      prestashop)
        sudo ${SCRIPT_DIR}/sudo/autodeploy-prestashop.sh ${DEPLOY_NAME} ${BRANCH_NAME} ${GL_USER}
        ;;
      wordpress)
        sudo ${SCRIPT_DIR}/sudo/autodeploy-wordpress.sh ${DEPLOY_NAME} ${BRANCH_NAME} ${GL_USER}
        ;;
      symfony)
        sudo ${SCRIPT_DIR}/sudo/autodeploy-symfony.sh ${DEPLOY_NAME} ${BRANCH_NAME} ${GL_USER}
        ;;
      *)
        echo "!!! ERROR: unsupported deployType '${DEPLOY_TYPE}'"
        #TODO: consistent error code handling
        exit 1
        ;;
    esac
    ROBOTS_DISALLOW=$(git config "hooks.deployB${BRANCH_NAME}RobotsDisallow")
    if [ "${ROBOTS_DISALLOW}" = 'true' ]; then
      WEB_ROOT=$(git config hooks.deployRoot)
      : ${WEB_ROOT:="/var/www"}
      SUBDIR=$(git config hooks.deploySubdir)
      sudo ${SCRIPT_DIR}/sudo/robots_disallow.sh "${WEB_ROOT}/${DEPLOY_NAME}/${SUBDIR}"
    fi
    #TODO: Implement a default as in drupal-profile
    MAIL_LIST=$(git config hooks.deployB${BRANCH_NAME}Notify)
    if [ ! "${MAIL_LIST}" = '' ]; then
      #git log --name-status $2..$3 | mail -s "Automatic deployment done on ${DEPLOY_NAME}" ${MAIL_LIST}
      INTERVAL="$2..$3"
      DIFF_FILE="/tmp/$INTERVAL.diff"
      git diff $INTERVAL > $DIFF_FILE
      git log --name-status $INTERVAL | iconv -f utf8 -t ASCII//TRANSLIT | mail -s "Automatic deployment done on ${DEPLOY_NAME}" -a ${DIFF_FILE} ${MAIL_LIST}
      rm $DIFF_FILE
    fi
  fi
fi

exit 0
