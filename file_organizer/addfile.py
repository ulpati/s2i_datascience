import os
import shutil
import csv
import argparse

def gestione_file(file, directory, extensions, file_csv):

    name, ext = os.path.splitext(file)
    size = os.path.getsize(os.path.join(directory, file))

    # verifico estensione file
    if ext in extensions:
        size = os.path.getsize(os.path.join(directory, file))
        f_type = extensions.get(ext)
        
        # sposto file controllando prima se esiste la cartella, altrimenti la creo
        if not os.path.isdir(os.path.join(directory, f_type)): os.mkdir(os.path.join(directory, f_type))
        shutil.move(os.path.join(directory, file), os.path.join(directory, f_type))

        # stampo informazioni file        
        print(f"{name} type:{f_type} size:{size}B")

        # scrivo su recap.csv
        writer = csv.writer(file_csv)
        writer.writerow( [name, f_type, size] )

# estensioni file accettate
extensions = {
    '.jpeg': 'images',
    '.jpg': 'images',
    '.png': 'images',
    '.txt': 'docs',
    '.odt': 'docs',
    '.mp3': 'audio',
}

directory = r'files' # r per interpretare letterlamente la stringa

# lista di file nella cartella con una delle estensioni accettate
file_choices = [file for file in os.listdir(directory) if os.path.splitext(file)[1] in extensions]
file_choices = sorted(file_choices)

# creo recap.csv se non esiste
recap = "recap.csv"
if not os.path.exists(os.path.join(directory, recap)):
    with open(os.path.join(directory, recap), "w", newline="") as file_csv_w:  # w = write mode
        writer = csv.writer(file_csv_w)
        writer.writerow(["name", "type", "size(B)"])

# estensioni accettate
accepted_extensions = ", ".join(extensions.keys())
help_message = f"Questo script può elaborare i seguenti tipi di file: {accepted_extensions}"

# Command Line Interface
parser = argparse.ArgumentParser()
parser.add_argument("f_name", help="Inserire nome file desiderato", choices=file_choices)
args = parser.parse_args()

with open(os.path.join(directory, "recap.csv"), "a", newline="") as file_csv_a: # a = append mode
    gestione_file(args.f_name, directory, extensions, file_csv_a)