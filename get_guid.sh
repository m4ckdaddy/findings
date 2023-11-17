#!/bin/bash

http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/" > app-guid.json
# Path to the JSON file containing the application data
JSON_FILE="./app-guid.json"

# Prompt user for the application name
read -p "Which application do you want to search for? " app_name

# Use jq to parse the JSON file and extract the application with the given name (case-insensitive)
app_guid=$(jq -r --arg APP_NAME "$app_name" '._embedded.applications[] | select(.profile.name | ascii_upcase | contains($APP_NAME | ascii_upcase)) | 
.guid' "$JSON_FILE")

# Check if an app_guid was found
if [[ -n "$app_guid" ]]; then
    echo "The GUID for '$app_name' is: $app_guid"
else
    echo "No application found with the name '$app_name'."
fi



http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v2/applications/$app_guid/findings/" > findings.json
