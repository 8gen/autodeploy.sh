#!/bin/bash

function update() {
    ID=$1
    REPO_ROOT=$2
    DEPLOY_ROOT=$3
    NAME=$4
    URL=$5
    CHANNEL_ID=$6
    BUILD_SUBDIR=$7
    if [[ $BUILD_SUBDIR == "" ]];then
        BUILD_SUBDIR="assets"
    fi

    LOCKFILE=/tmp/${ID}.lock
    if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
        echo "already running"
        exit
    fi

    trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
    echo $$ > ${LOCKFILE}

    cd $REPO_ROOT
    OLD_HEAD=$(git rev-parse --verify HEAD)
    git checkout .
    git clean -fx
    git pull
    NEW_HEAD=$(git rev-parse --verify HEAD)
    changelog="$(git log --pretty=format:'%s' $OLD_HEAD..HEAD | sed 's|^|- |g')"

    if [[ $OLD_HEAD != $NEW_HEAD ]];then
        rm -rf ${BUILD_SUBDIR}
        npm install
        make build > /tmp/${ID}_build.log 2>&1
        if [[ $? != 0 ]]; then
        message="*Dev ${NAME} failed update*\n\n*Changelog:*\n${changelog}\n*Error log:*\n$(cat /tmp/${ID}_build.log)"
        else
        rm -rf ${DEPLOY_ROOT}
        cp -r ${BUILD_SUBDIR} ${DEPLOY_ROOT}
        message="*Dev ${NAME} updated*\nSite is Ready to test - ${URL}\n\n*Changelog:*\n${changelog}"
        fi
        echo -e "&parse_mode=Markdown&text=${message}" > /tmp/upload_${ID}.txt
        cat /tmp/upload_${ID}.txt | curl -i -X POST  "https://api.telegram.org/__BOTID__:__BOTAPIKEY__/sendMessage?chat_id=${CHANNEL_ID}" --data-binary @-
    fi
    rm -f ${LOCKFILE}
}
