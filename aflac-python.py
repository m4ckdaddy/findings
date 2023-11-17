import json
import csv

def extract_findings_to_csv(input_file_path, output_file_path):
    # Load the JSON data from the file
    with open(input_file_path, 'r') as file:
        findings_data = json.load(file)

    # Extracting the findings from the JSON data
    findings = findings_data.get('_embedded', {}).get('findings', [])

    # Define the headers
    headers = ['build_id', 'context_guid', 'context_type', 'count', 'description',
               'issue_id', 'scan_type', 'violates_policy', 'first_found_date',
               'last_seen_date', 'mitigation_review_status', 'resolution_status']

    # Write the data to a CSV file
    with open(output_file_path, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=headers)
        writer.writeheader()

        for finding in findings:
            # Clean up description to remove new lines and tabs
            description = finding.get('description', '').replace('\n', ' ').replace('\t', ' ')

            writer.writerow({
                'build_id': finding.get('build_id', ''),
                'context_guid': finding.get('context_guid', ''),
                'context_type': finding.get('context_type', ''),
                'count': finding.get('count', ''),
                'description': description,
                'issue_id': finding.get('issue_id', ''),
                'scan_type': finding.get('scan_type', ''),
                'violates_policy': finding.get('violates_policy', ''),
                'first_found_date': finding.get('first_found_date', ''),
                'last_seen_date': finding.get('last_seen_date', ''),
                'mitigation_review_status': finding.get('mitigation_review_status', ''),
                'resolution_status': finding.get('resolution_status', '')
            })

# Replace these file paths with the actual paths
input_file = 'findings.json'
output_file = 'findings_extracted.csv'

extract_findings_to_csv(input_file, output_file)
