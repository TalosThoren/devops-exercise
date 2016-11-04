#!/bin/bash

# Find tools
CURL=$(which curl)
JQ=$(which jq)

# Options required to collect return code from curl requests
CURL_OPTIONS="--write-out \"%{http_code}\" --silent --output /dev/null"

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
    healthy_result='"200"'
    msg="check_health_auth"
    response_code=$($CURL -X GET "$AUTH_EP/health" $CURL_OPTIONS)
    echo $(validate_response $healthy_result $response_code $msg)
}

check_health_data() {
    healthy_result='"200"'
    msg="check_health_data"
    response_code=$($CURL -X GET "$DATA_EP/health" $CURL_OPTIONS)
    echo $(validate_response $healthy_result $response_code $msg)
}

check_get_token() {
    healthy_result='"201"'
    msg="check_get_token"
    response_code=$($CURL -X GET "$AUTH_EP/token?key=$TEST_KEY&secret=$TEST_SECRET" $CURL_OPTIONS)
    echo $(validate_response $healthy_result $response_code $msg)
}

check_post_accounts() {
    healthy_result='"201"'
    msg="check_post_account()"
    token_header="token: $(get_token)"
    response_code=$($CURL -X POST "$DATA_EP/accounts?name=$TEST_NAME&valuation=$TEST_VALUE&employees=$TEST_EMP_CT" -H "$token_header" $CURL_OPTIONS)
    echo $(validate_response $healthy_result $response_code $msg)
}

check_get_accounts() {
    healthy_result='"200"'
    msg="check_get_accounts"
    token_header="token: $(get_token)"
    response_code=$($CURL -X GET "$DATA_EP/accounts" -H "$token_header" $CURL_OPTIONS)
    echo $(validate_response $healthy_result $response_code $msg)
}

validate_response() {
    if [[ $1 == $2 ]]; then
        echo $(psuccess $2 $3)
    else
        echo $(perror $2 $3)
    fi
}

psuccess() {
    printf "SUCCESS: %s returned status code: %s" "$2" "$1"
}

perror() {
    printf "ERROR: %s returned status code: %s" "$2" "$1"
}

# Let's obtain a token expects the jq tool to be in your path
get_token() {
    response=$($CURL -X GET "$AUTH_EP/token?key=$TEST_KEY&secret=$TEST_SECRET" --silent)
    echo ${response} | jq '.[]' --raw-output
}

# Run checks
main() {
    echo $(check_health_auth)
    echo $(check_health_data)
    echo $(check_get_token)
    echo $(check_post_accounts)
    echo $(check_get_accounts)
}

# Execute main
main
