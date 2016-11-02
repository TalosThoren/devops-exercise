#!/bin/bash

# Find tools
CURL=$(which curl)
JQ=$(which jq)

#Endpoints
AUTH_EP="http://0.0.0.0/api/auth"
DATA_EP="http://0.0.0.0/api/data"

# Test key and secret hardcoded for now. Could replace with awk commands
# and pull from test/data/user.json in the future
TEST_KEY="abc1234567890"
TEST_SECRET="mnb0987654321"

# Dummy Data to create a new account
TEST_NAME="google"
TEST_VALUE="9999999"
TEST_EMP_CT="3000"

check_health_auth() {
    $CURL -X GET "$AUTH_EP/health" \
        --write-out "%{http_code}" \
        --silent \
        --output /dev/null
}

check_health_data() {
    $CURL -X GET "$DATA_EP/health" \
        --write-out "%{http_code}" \
        --silent \
        --output /dev/null
}

check_get_token() {
    $CURL -X GET "$AUTH_EP/token?key=$TEST_KEY&secret=$TEST_SECRET" \
        --write-out "%{http_code}" \
        --silent \
        --output /dev/null
}

check_post_accounts() {
    token_header="token: $(get_token)"
    $CURL -X POST "$DATA_EP/accounts?name=$TEST_NAME&valuation=$TEST_VALUE&employees=$TEST_EMP_CT" \
        -H "$token_header" \
        --write-out "%{http_code}" \
        --silent \
        --output /dev/null
}

check_get_accounts() {
    token_header="token: $(get_token)"
    $CURL -X GET "$DATA_EP/accounts" \
        -H "$token_header" \
        --write-out "%{http_code}" \
        --silent \
        --output /dev/null
}

# Let's obtain a token expects the jq tool to be in your path
get_token() {
    response=$($CURL -X GET "$AUTH_EP/token?key=$TEST_KEY&secret=$TEST_SECRET")
    echo ${response} | jq '.[]' --raw-output
}

# Run checks
if [[ '200' != $(check_health_auth) ]]; then
    echo "ERROR: check_health_auth failed to return 200"
fi

if [[ '200' != $(check_health_data) ]]; then
    echo "ERROR: check_health_data failed to return 200"
fi

if [[ '201' != $(check_get_token) ]]; then
    echo "ERROR: check_get_token failed to return 201"
    exit 1
fi

if [[ '201' != $(check_post_accounts) ]]; then
    echo "ERROR: check_post_accounts failed to return 201"
    exit 1
fi

if [[ '200' != $(check_get_accounts) ]]; then
    echo "ERROR: check_get_accounts failed to return 200"
    exit 1
fi

echo "SUCCESS: All curl checks pass!"
