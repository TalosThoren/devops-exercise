#!/bin/bash

# MongoImport script. To be run from mounted /test/data within mongodb container
MONGO_SHELL=$(which mongo)
MONGO_IMPORT=$(which mongoimport)
TEST_DATA_PATH="/test/data"
DATA_IMPORT_ARGS="--db data --collection accounts $TEST_DATA_PATH/account.json"
USER_IMPORT_ARGS="--db auth --collection users $TEST_DATA_PATH/user.json"

# Check if databases already exist
database_names=$($MONGO_SHELL --eval "db.getMongo().getDBNames()")
data_db_exists=0
auth_db_exists=0

for each in $database_names; do
    string=$(echo $each | awk -F'"' '$0=$2')
    if [[ "$string" == "auth" ]]; then
        auth_db_exists=1
    fi
    if [[ "$string" == "data" ]]; then
        data_db_exists=1
    fi
done

# Import mongo test data
if [[ 0 == $auth_db_exists ]]; then
    $MONGO_IMPORT $DATA_IMPORT_ARGS
fi
if [[ 0 == $data_db_exists ]]; then
    $MONGO_IMPORT $USER_IMPORT_ARGS
fi
