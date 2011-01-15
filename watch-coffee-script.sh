#!/usr/bin/env bash

COFFEE_PATH="./lib/coffee-script/bin"
JSL_PATH="./lib/jsl"

export PATH=${COFFEE_PATH}:${JSL_PATH}:${PATH}

PROD_SRC_FILES="./production/src/coffee-script/*.coffee"
PROD_OUT_DIR="./production/src/js/"
TEST_SRC_FILES="./test/src/coffee-script/*.coffee"
TEST_OUT_DIR="./test/src/js/"

coffee --lint --watch --output ${TEST_OUT_DIR} --compile ${TEST_SRC_FILES} &
coffee --lint --watch --output ${PROD_OUT_DIR} --compile ${PROD_SRC_FILES}
