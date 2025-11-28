import os
import shutil
import csv
import argparse

def manage_file(file, directory, extensions, file_csv):

    name, ext = os.path.splitext(file)
    size = os.path.getsize(os.path.join(directory, file))

    # check file extension
    if ext in extensions:
        size = os.path.getsize(os.path.join(directory, file))
        f_type = extensions.get(ext)
        
        # move file, creating target folder if it doesn't exist
        if not os.path.isdir(os.path.join(directory, f_type)): os.mkdir(os.path.join(directory, f_type))
        shutil.move(os.path.join(directory, file), os.path.join(directory, f_type))

        # print file information       
        print(f"{name} type:{f_type} size:{size}B")

        # write to recap.csv
        writer = csv.writer(file_csv)
        writer.writerow( [name, f_type, size] )

# accepted file extensions
extensions = {
    '.jpeg': 'images',
    '.jpg': 'images',
    '.png': 'images',
    '.txt': 'docs',
    '.odt': 'docs',
    '.mp3': 'audio',
}

directory = r'files' # raw string for folder path

# list files in the folder that have one of the accepted extensions
file_choices = [file for file in os.listdir(directory) if os.path.splitext(file)[1] in extensions]
file_choices = sorted(file_choices)

# create recap.csv if it does not exist
recap = "recap.csv"
if not os.path.exists(os.path.join(directory, recap)):
    with open(os.path.join(directory, recap), "w", newline="") as file_csv_w:  # w = write mode
        writer = csv.writer(file_csv_w)
        writer.writerow(["name", "type", "size(B)"])

# accepted extensions (for help text)
accepted_extensions = ", ".join(extensions.keys())
help_message = f"This script processes the following file types: {accepted_extensions}"

# Command Line Interface
parser = argparse.ArgumentParser(description=help_message)
parser.add_argument("f_name", help="Name of the file to move (include extension)", choices=file_choices)
args = parser.parse_args()

with open(os.path.join(directory, "recap.csv"), "a", newline="") as file_csv_a: # a = append mode
    manage_file(args.f_name, directory, extensions, file_csv_a)