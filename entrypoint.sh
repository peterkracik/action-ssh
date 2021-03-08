#!/bin/bash

set -eu

BLUE='\033[0;34m'
NORMAL='\033[0m'


mkdir -p ~/.ssh/
install -m 600 /dev/null ~/.ssh/id_rsa
echo "${INPUT_PRIVATEKEY}" > ~/.ssh/id_rsa

install -m 700 /dev/null ~/script.sh
echo '# Environment variables:' >> ~/script.sh
env -0 | while read -r -d '' line; do
    # Skip unnecessary env vars, wrap the single- or multiline value in single quotes, escape existing single quotes.
    [[ ! ${line} =~ ^(HOSTNAME=|HOME=|INPUT_) ]] && echo "${line%%=*}='$(echo "${line#*=}" | sed "s/'/'\\\\''/g")'" >> ~/script.sh
done
echo '' >> ~/script.sh

echo '# CD to the folder ${INPUT_PATH}' >> ~/script.sh
echo "cd ${INPUT_PATH}" >> ~/script.sh    

echo '# Commands:' >> ~/script.sh
echo "${INPUT_COMMAND}" >> ~/script.sh

echo ""
echo -e "${BLUE}Run on:${NORMAL} ${INPUT_HOST} in ${INPUT_PATH}"
echo -e "${BLUE}Commands:${NORMAL}"
if [[ "${INPUT_DEBUG}" = "true" ]] || [[ "${INPUT_DEBUG}" = "1" ]]; then
    cat ~/script.sh
else
    cat ~/script.sh | sed '1,/^# Commands:$/d'
fi
echo ""

# set path part of the ssh connection or leave it empty


echo -e "${BLUE}Connecting to ${INPUT_HOST}...${NORMAL}"
sh -c "ssh -q -t -i ~/.ssh/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no '${INPUT_HOST}' < ~/script.sh"
echo ""

echo ""
echo -e "${BLUE}GitHub Action completed.${NORMAL}"
