#!/bin/bash
#http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=0&size=100" > applications.json

# Define the JSON file path
#JSON_FILE="applications.json"

# Use jq to parse the JSON and extract ID, GUID, and Name
#jq -r '.["_embedded"].applications[] | "\(.id) \(.guid) \(.profile.name)"' $JSON_FILE

#echo $JSON_FILE > app_guid.json


# Define the output CSV file path
#CSV_FILE="output.csv"

# Use jq to parse the JSON and convert it to CSV
#echo "ID,GUID,Name" > $CSV_FILE
#jq -r '.["_embedded"].applications[] | "\(.id),\(.guid),\(.profile.name)"' $JSON_FILE >> $CSV_FILE
# Path to the JSON file containing the application data
http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v1/applications/?page=0&size=100" > app-guid.json
JSON_FILE="./app-guid.json"

# Prompt user for the application name
read -p "Which application do you want to search for? " app_name

# Use jq to parse the JSON file and extract the application with the given name (case-insensitive)
app_guid=$(jq -r --arg APP_NAME "$app_name" '._embedded.applications[] | select(.profile.name | ascii_upcase | contains($APP_NAME | ascii_upcase)) | .guid' "$JSON_FILE")

# Check if an app_guid was found
if [[ -n "$app_guid" ]]; then
    echo "The GUID for '$app_name' is: $app_guid"
else
    echo "No application found with the name '$app_name'."
fi



http --auth-type=veracode_hmac GET "https://api.veracode.com/appsec/v2/applications/$app_guid/findings/" > findings.json
python3 aflac-python.py
# Define the input JSON file and the output CSV file
json_input="findings.json"
csv_output="findings_converted.csv"

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install jq to run this script."
    exit 1
fi

# Extract and transform data from JSON to CSV
echo "build_id,context_guid,context_type,count,description,issue_id,scan_type,violates_policy,first_found_date,last_seen_date,mitigation_review_status,resolution_status" > "$csv_output"
jq -r '.["_embedded"]["findings"][] | [.build_id, .context_guid, .context_type, .count, .description, .issue_id, .scan_type, .violates_policy, .finding_status.first_found_date, .finding_status.last_seen_date, .finding_status.mitigation_review_status, .finding_status.resolution_status] | @csv' "$json_input" >> "$csv_output"

echo "Conversion completed. Output saved to $csv_output"
#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 $csv_output"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    usage
fi

# Assign the argument to a variable
echo $csv_output=CSV_FILE

# Check if the file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: File $CSV_FILE not found."
    exit 1
fi

# Prompt the user for the application name
read -p "Enter the application name: " APPLICATION_NAME

# Check if the application name is empty
if [ -z "$APPLICATION_NAME" ]; then
    echo "Error: No application name provided."
    exit 1
fi

# Create a temporary file for the output
TEMP_FILE=$(mktemp)

# Add the new column header
echo "$(head -1 $CSV_FILE),application_name" > $TEMP_FILE

# Add the new column values
tail -n +2 $CSV_FILE | awk -v app_name="$APPLICATION_NAME" -F, '{print $0","app_name}' >> $TEMP_FILE

# Move the temporary file to the original file
mv $TEMP_FILE $CSV_FILE

