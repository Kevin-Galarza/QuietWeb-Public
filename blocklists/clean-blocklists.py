import os

def process_file(file_path):
    with open(file_path, 'r') as file:
        # Read all lines and process them
        lines = file.readlines()
    
    # Remove the first two characters from each line and strip any extra whitespace
    processed_lines = [line[2:].strip() for line in lines]
    
    # Remove duplicates by converting the list to a set, then back to a list to preserve order
    unique_lines = list(dict.fromkeys(processed_lines))
    
    # Write the processed lines back to the file
    with open(file_path, 'w') as file:
        file.write('\n'.join(unique_lines) + '\n')

def process_directory(directory_path):
    # Iterate over all files in the directory, processing each one
    for filename in os.listdir(directory_path):
        # Ignore .DS_Store files
        if filename == ".DS_Store":
            continue
        
        file_path = os.path.join(directory_path, filename)
        if os.path.isfile(file_path):  # Ensure it's a file
            process_file(file_path)
            print(f"Processed file: {file_path}")

if __name__ == "__main__":
    directory_path = input("Enter the directory path: ")
    process_directory(directory_path)
    print("Processing complete.")
