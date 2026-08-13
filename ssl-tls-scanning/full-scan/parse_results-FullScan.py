# Required external dependencies
import os, sys, subprocess

# Set the file path for the PowerShell script
# Replace with the path to this script in your own environment
PS_FILE_PATH = "C:\\Scripts\\SSL-TLS-Scans\\FullScan\\nmap_scan-FullScan.ps1"

def main():

    # Run the PowerShell script that will execute our Nmap scan
    process = subprocess.Popen(["powershell.exe", PS_FILE_PATH], stdout=sys.stdout)
    process.communicate()

    # Store the results of the Nmap scan into a list
    with open("raw_nmap_scan.txt") as input_file:
        input_data = input_file.read().splitlines()

    os.remove("raw_nmap_scan.txt")

    # Parse the list to produce a clean formatted output based on configuration
    with open("cleaned_nmap_scan.txt", 'w') as output_file:
        for line in input_data:
            if "Nmap scan report for" in line:
                output_file.write("IP: " + str(line.split("for ", 1)[1]) + "\n")
            if "/tcp" in line:
                output_file.write(' '*4 + "Port: " + str(line.split('/', 1)[0]) + "\n")
            if "TLSv" in line:
                output_file.write(' '*8 + "TLSv" + str(line.split('v', 1)[1].replace(':', '') + " enabled.") + "\n")
            if "SSLv" in line:
                output_file.write(' '*8 + "SSLv" + str(line.split('v', 1)[1].replace(':', '') + " enabled.") + "\n")

if __name__ == '__main__':
    main()
