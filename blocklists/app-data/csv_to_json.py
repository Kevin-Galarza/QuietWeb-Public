import sys
import csv
import json
import re

# USAGE: python3 script.py input.csv output.json 1

def generate_id(name):
    # Convert to lowercase and replace spaces with hyphens
    clean_name = re.sub(r'[^a-zA-Z0-9\s]', '', name)  # Remove special characters except spaces
    clean_name = clean_name.lower().replace(' ', '-')  # Replace spaces with hyphens
    return clean_name

def csv_to_json(input_file, output_file, group):
    sources = []

    with open(input_file, 'r') as csvfile:
        csvreader = csv.reader(csvfile)
        for row in csvreader:
            if row:  # Ensure the row is not empty
                source_name = row[0].strip()
                hosts = [host.strip() for host in row[1:] if host.strip()]  # Ignore empty strings
                source_id = generate_id(source_name)
                source = {
                    "id": source_id,
                    "group": group,  # Add the group parameter to each source object
                    "name": source_name,
                    "hosts": hosts
                }
                sources.append(source)
    
    with open(output_file, 'w') as jsonfile:
        json.dump(sources, jsonfile, indent=4)
    
    print(f"JSON file '{output_file}' has been created.")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <input_csv_file> <output_json_file> <group>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        group = int(sys.argv[3])  # Convert the group parameter to an integer
        csv_to_json(input_file, output_file, group)

